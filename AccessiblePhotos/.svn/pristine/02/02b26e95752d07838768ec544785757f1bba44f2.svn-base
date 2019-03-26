//
//  AudioRecorder.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/30.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//


#import "AudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

#define SAMPLES_PER_SECOND	8000.0f
#define kAudioConverterPropertyMaximumOutputPacketSize		'xops'
#define BUFFER_DURATION 0.5

#define NUM_BUFFERS 3

typedef struct
{
    BOOL                        isInitialized;
    AudioFileID                 audioFile;
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         buffers[NUM_BUFFERS];
    UInt32                      bufferByteSize;
    SInt64                      currentPacket;
    BOOL                        isRecording;
    
    
    UInt32                      circularQueueBufferCount;
    AudioQueueBufferRef*        circularQueueOfBuffers;
    BOOL                        isCircularQueueIsFull;
    SInt32                      circularQueueOfBuffersHeadIndex;
    
} RecordState;

// Derive the Buffer Size.
void DeriveBufferSize (AudioQueueRef audioQueue, AudioStreamBasicDescription ASBDescription, Float64 seconds, UInt32 *outBufferSize)
{
    static const int maxBufferSize = 0x50000;
    int maxPacketSize = ASBDescription.mBytesPerPacket; 
    if (maxPacketSize == 0) 
	{                           
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty(audioQueue, kAudioConverterPropertyMaximumOutputPacketSize, &maxPacketSize, &maxVBRPacketSize);
    }
    
    Float64 numBytesForTime = ASBDescription.mSampleRate * maxPacketSize * seconds;
    *outBufferSize =  (UInt32)((numBytesForTime < maxBufferSize) ? numBytesForTime : maxBufferSize);
}

// Handle new input
static void HandleInputBuffer(void *aqData,
                              AudioQueueRef inAQ,
                              AudioQueueBufferRef inBuffer,
                              const AudioTimeStamp *inStartTime,
                              UInt32 inNumPackets,
                              const AudioStreamPacketDescription *inPacketDesc)
{
    RecordState *recordState = (RecordState *)aqData;
    
    if (recordState->isInitialized)
    {
        if (inNumPackets == 0 && recordState->dataFormat.mBytesPerPacket != 0)
        {
            // Constant bit-rate data
            inNumPackets = inBuffer->mAudioDataByteSize / recordState->dataFormat.mBytesPerPacket;
        }
        
        recordState->circularQueueOfBuffersHeadIndex++;
        if (recordState->circularQueueOfBuffersHeadIndex >= recordState->circularQueueBufferCount)
        {
            recordState->circularQueueOfBuffersHeadIndex = 0;
            recordState->isCircularQueueIsFull = YES;
        }
        
        // Allocate a copy buffer, if not already
        if (recordState->circularQueueOfBuffers[recordState->circularQueueOfBuffersHeadIndex] == NULL)
        {
            OSStatus status;
            // Allocate copy buffer
            status = AudioQueueAllocateBuffer(inAQ, inBuffer->mAudioDataByteSize, &recordState->circularQueueOfBuffers[recordState->circularQueueOfBuffersHeadIndex]);
            if (status) { fprintf(stderr, "ERROR: Could not create copy of audio buffer\n"); return; }
        }
        
        // Copy the audio data
        recordState->circularQueueOfBuffers[recordState->circularQueueOfBuffersHeadIndex]->mAudioDataByteSize = inBuffer->mAudioDataByteSize;
        memcpy(recordState->circularQueueOfBuffers[recordState->circularQueueOfBuffersHeadIndex]->mAudioData, inBuffer->mAudioData, inBuffer->mAudioDataByteSize);
        
        recordState->currentPacket += inNumPackets;
        // Don't re-queue the buffer if the recording state is NO
        if (recordState->isRecording == 0)
        {
            return;
        }
        AudioQueueEnqueueBuffer (recordState->queue, inBuffer, 0, NULL);
    }
}

@implementation AudioRecorder
{
	RecordState recordState;
    NSString *recordingFilePath;
    UInt32 circularQueueBufferCount;
    BOOL waitingToSaveFile;
}

@synthesize maxRecordingDuration = _maxRecordingDuration;
@synthesize delegate;

// Initialize the recorder
- (id)init
{
    if (self = [super init])
    {
        recordState.isRecording = NO;
        recordState.circularQueueOfBuffersHeadIndex = -1;
        
        // Initialize with default max duration.
        self.maxRecordingDuration = 1.0;
    }
    return self;
}

#pragma mark - Property accessor overrides

// Return whether the recording is active
- (BOOL)isRecording
{
    return recordState.isRecording;
}

- (CGFloat)averagePower
{
    AudioQueueLevelMeterState state[1];
    UInt32  statesize = sizeof(state);
    OSStatus status;
    status = AudioQueueGetProperty(recordState.queue, kAudioQueueProperty_CurrentLevelMeter, &state, &statesize);
    if (status) {fprintf(stderr, "ERROR: Error retrieving meter data\n"); return 0.0f;}
    return state[0].mAveragePower;
}

- (CGFloat)peakPower
{
    AudioQueueLevelMeterState state[1];
    UInt32  statesize = sizeof(state);
    OSStatus status;
    status = AudioQueueGetProperty(recordState.queue, kAudioQueueProperty_CurrentLevelMeter, &state, &statesize);
    if (status) {fprintf(stderr, "ERROR: Error retrieving meter data\n"); return 0.0f;}
    return state[0].mPeakPower;
}

// Return the current time
- (NSTimeInterval)currentTime
{
    AudioTimeStamp outTimeStamp;
    OSStatus status = AudioQueueGetCurrentTime (recordState.queue, NULL, &outTimeStamp, NULL);
    if (status) {fprintf(stderr, "ERROR: Could not retrieve current time\n"); return 0.0f;}
    return outTimeStamp.mSampleTime / SAMPLES_PER_SECOND;
}

- (NSTimeInterval)maxRecordingDuration
{
    return _maxRecordingDuration;
}

- (void)setMaxRecordingDuration:(NSTimeInterval)newMaxRecordingDuration
{
    if (newMaxRecordingDuration != _maxRecordingDuration)
    {
        _maxRecordingDuration = newMaxRecordingDuration;
        circularQueueBufferCount = ceil(newMaxRecordingDuration / BUFFER_DURATION);
    }
}

#pragma mark - Public instance methods

// Begin recording
- (BOOL)startRecording:(NSString *)filePath
{
    NSLog(@"############# AudioRecorder: startRecording");
    
    if (recordState.isRecording)
    {
        return NO;
    }
    
    [self resetRecordState];
    [self changeCircularQueueBufferCountTo:circularQueueBufferCount];
    
    recordingFilePath = [filePath copy];
    CFURLRef fileURL =  CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *) [filePath UTF8String], [filePath length], NO);
    
	// new input queue
    OSStatus status;
    status = AudioQueueNewInput(&recordState.dataFormat, HandleInputBuffer, &recordState, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &recordState.queue);
    if (status) { CFRelease(fileURL); fprintf(stderr, "ERROR: Could not establish new queue\n"); return NO; }
    
	// create new audio file
    status = AudioFileCreateWithURL(fileURL, kAudioFileAIFFType, &recordState.dataFormat, kAudioFileFlags_EraseFile, &recordState.audioFile);
	CFRelease(fileURL);
    if (status) {fprintf(stderr, "ERROR: Could not create file to record audio\n"); return NO;}
    
	// figure out the buffer size
    DeriveBufferSize(recordState.queue, recordState.dataFormat, BUFFER_DURATION, &recordState.bufferByteSize);
	
	// allocate those buffers and enqueue them
    for (int i = 0; i < NUM_BUFFERS; i++)
    {
        status = AudioQueueAllocateBuffer(recordState.queue, recordState.bufferByteSize, &recordState.buffers[i]);
        if (status) {fprintf(stderr, "ERROR: Error allocating buffer %d\n", i); return NO;}
        
        status = AudioQueueEnqueueBuffer(recordState.queue, recordState.buffers[i], 0, NULL);
        if (status) {fprintf(stderr, "ERROR: Error enqueuing buffer %d\n", i); return NO;}
    }
	
	// enable metering
    UInt32 enableMetering = YES;
    status = AudioQueueSetProperty(recordState.queue, kAudioQueueProperty_EnableLevelMetering, &enableMetering,sizeof(enableMetering));
    if (status) {fprintf(stderr, "ERROR: Could not enable metering\n"); return NO;}
    
	// start recording
    recordState.isRecording = YES;
    recordState.isInitialized = YES;
    status = AudioQueueStart(recordState.queue, NULL);
    if (status)
    {
        recordState.isRecording = NO;
        fprintf(stderr, "ERROR: Could not start Audio Queue\n");
        return NO;
    }
    return YES;
}

// Stop the recording after waiting just a second
- (void)stopRecordingAndKeepAudioFile:(BOOL)keepAudioFile
{
    NSLog(@"########## AudioRecorder: stopRecording called. recording=%d waitingToSaveFile=%d", recordState.isRecording, waitingToSaveFile);
    
    if (recordState.isRecording == YES && waitingToSaveFile == NO)
    {
        waitingToSaveFile = YES;
        [self performSelector:@selector(reallyStopRecording:) withObject:[NSNumber numberWithBool:keepAudioFile] afterDelay:(BUFFER_DURATION * 2.0f)];
    }
}

- (void)pause
{
    if (recordState.isRecording)
    {
        [self performSelector:@selector(reallyPauseRecording) withObject:NULL afterDelay:(BUFFER_DURATION)];
    }
}

- (BOOL)resume
{
    if (!recordState.queue){fprintf(stderr, "Nothing to resume\n"); return NO;}
    OSStatus status = AudioQueueStart(recordState.queue, NULL);
    if (status) {fprintf(stderr, "ERROR: Error restarting audio queue\n"); return NO;}
    return YES;
}

#pragma mark - Private instance methods

- (UInt32)circularQueueOfBuffersTailIndex
{
    if (recordState.isCircularQueueIsFull == NO)
    {
        return 0;
    }
    return (recordState.circularQueueOfBuffersHeadIndex + 1) % recordState.circularQueueBufferCount;
}

// Set up the recording format as low quality mono AIFF
- (void)setupAudioFormat:(AudioStreamBasicDescription*)format
{
    format->mSampleRate = SAMPLES_PER_SECOND;
    format->mFormatID = kAudioFormatLinearPCM;
    format->mFormatFlags = kLinearPCMFormatFlagIsBigEndian |  kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    format->mChannelsPerFrame = 2;
    format->mBitsPerChannel = 16;
    format->mFramesPerPacket = 1;
    format->mBytesPerPacket = 4;
    format->mBytesPerFrame = 4;
    format->mReserved = 0;
}

- (void)resetRecordState
{
    recordState.isInitialized = FALSE;
    if (recordState.audioFile != NULL)
    {
        OSStatus status = AudioFileClose(recordState.audioFile);
        if (status) { fprintf(stderr, "ERROR: Unable to close audio file."); }
        recordState.audioFile = NULL;
    }
    [self setupAudioFormat:&recordState.dataFormat];
    
    [self changeCircularQueueBufferCountTo:0];
    
    if (recordState.queue != NULL)
    {
        for (int i = 0; i < NUM_BUFFERS; i++)
        {
            AudioQueueFreeBuffer(recordState.queue, recordState.buffers[i]);
            recordState.buffers[i] = NULL;
        }
        AudioQueueDispose(recordState.queue, YES);
        recordState.queue = NULL;
    }
	// figure out the buffer size
    recordState.bufferByteSize = 0;
    recordState.currentPacket = 0;
    recordState.isRecording = FALSE;
}

- (void)reallyPauseRecording
{
	if (!recordState.queue) {fprintf(stderr, "Nothing to pause\n"); return;}
    OSStatus status = AudioQueuePause(recordState.queue);
    if (status) {fprintf(stderr, "ERROR: Error pausing audio queue\n"); return;}
}

// There's generally about a one-second delay before the buffers fully empty
- (void)reallyStopRecording:(id)arg
{
    BOOL keepAudioFile = [arg boolValue];
    
    NSLog(@"############# AudioRecorder: reallyStopRecording called: keepAudioFile = %d", keepAudioFile);
    
    AudioQueueFlush(recordState.queue);
    AudioQueueStop(recordState.queue, NO);
    
    
    if (keepAudioFile)
    {
        // Write out circular buffer data to file
        // ASSUMING CBR
        int numBuffersToCopy = recordState.circularQueueBufferCount;
        int circularQueueOfBuffersTailIndex = [self circularQueueOfBuffersTailIndex];
        if (recordState.isCircularQueueIsFull == NO)
        {
            numBuffersToCopy = recordState.circularQueueOfBuffersHeadIndex + 1;
        }
        
        NSLog(@"########### Writing out %d buffers starting with buffer #%d up to buffer #%lu", numBuffersToCopy, circularQueueOfBuffersTailIndex, recordState.circularQueueOfBuffersHeadIndex);
        
        UInt32 currentPacket = 0;
        for(int i = 0; i < numBuffersToCopy; i++)
        {
            int index = (circularQueueOfBuffersTailIndex + i) % recordState.circularQueueBufferCount;
            
            if (recordState.circularQueueOfBuffers[index] == NULL)
            {
                NSLog(@"ERROR: encountered NULL copy buffer upon saving");
                continue;
            }
            UInt32 inNumPackets = recordState.circularQueueOfBuffers[index]->mAudioDataByteSize / recordState.dataFormat.mBytesPerPacket;
            
            NSLog(@"####  Writing out buffer #%d with %ld numPackets", index, inNumPackets);
            if (AudioFileWritePackets(recordState.audioFile, NO, recordState.circularQueueOfBuffers[index]->mAudioDataByteSize, NULL, currentPacket, &inNumPackets, recordState.circularQueueOfBuffers[index]->mAudioData) == noErr)
            {
                currentPacket += inNumPackets;
            }
            else
            {
                NSLog(@"ERROR: couldn't write packets to audio file");
            }
        }
    }
    
    //    // TODO: convert the file to compressed format
    //    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:recordingFilePath] options:nil];
    //    
    //    NSLog (@"###### compatible presets for songAsset: %@",
    //           [AVAssetExportSession exportPresetsCompatibleWithAsset:asset]);
    //    
    //    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    //    exporter.outputFileType = @"com.apple.m4a-audio";
    //    exporter.outputURL = [NSURL fileURLWithPath:[recordingFilePath stringByAppendingPathExtension:@"m4a"]];
    //    
    //    NSLog(@"About to export to %@", exporter.outputURL);
    //    
    //    [exporter exportAsynchronouslyWithCompletionHandler:^{
    //        NSLog(@"Finished exporting");
    //        switch (exporter.status)
    //        {
    //            case AVAssetExportSessionStatusFailed:
    //                NSLog(@"ERROR: AVAssetExportSessionStatusFailed: %@", exporter.error.localizedDescription);
    //                break;
    //            case AVAssetExportSessionStatusCompleted: NSLog (@"AVAssetExportSessionStatusCompleted"); break;
    //            case AVAssetExportSessionStatusUnknown: NSLog (@"AVAssetExportSessionStatusUnknown"); break;
    //            case AVAssetExportSessionStatusExporting: NSLog (@"AVAssetExportSessionStatusExporting"); break;
    //            case AVAssetExportSessionStatusCancelled: NSLog (@"AVAssetExportSessionStatusCancelled"); break;
    //            case AVAssetExportSessionStatusWaiting: NSLog (@"AVAssetExportSessionStatusWaiting"); break;
    //            default:  NSLog (@"didn't get export status"); break;
    //        }
    //    }];
    //    
    
    [self resetRecordState];
    
    NSString *recordedFilePath = [recordingFilePath copy];
    recordingFilePath = nil;
    waitingToSaveFile = NO;
    
    //FIX: distinguish between actual save of the file versus just stopping of recording?
    [self.delegate audioRecorder:self finishedRecordingToFile:recordedFilePath];
}

- (void)changeCircularQueueBufferCountTo:(UInt32)newBufferCount
{
    SInt32 oldHeadIndex = recordState.circularQueueOfBuffersHeadIndex;
    SInt32 oldTailIndex = [self circularQueueOfBuffersTailIndex];
    UInt32 oldBufferCount = recordState.circularQueueBufferCount;
    BOOL wasFull = recordState.isCircularQueueIsFull;
    
    // Allocate the new queue of buffers.
    AudioQueueBufferRef* newCircularQueueOfBuffers = NULL;
    if (newBufferCount > 0)
    {
        newCircularQueueOfBuffers = malloc(sizeof(AudioQueueBufferRef) * newBufferCount);
    }
    
    SInt32 newHeadIndex = -1;
    
    if (newBufferCount > recordState.circularQueueBufferCount)
    {
        // Copy over current values.
        int numBuffersToCopy = oldBufferCount;
        if (wasFull == NO)
        {
            numBuffersToCopy = oldHeadIndex + 1;
        }
        
        // Copy over the pointers to the pre-allocated buffers from the old queue to the new queue.
        for (int i = 0; i < newBufferCount; i++)
        {
            if (i < numBuffersToCopy)
            {
                // Simply copy the pointer to the pre-allocated buffers.
                newCircularQueueOfBuffers[i] = recordState.circularQueueOfBuffers[(oldTailIndex + i) % oldBufferCount];
                newHeadIndex++;
            }
            else
            {
                newCircularQueueOfBuffers[i] = NULL;
            }
        }
    }
    else
    {
        // Shrink the buffer, keeping only the most recent buffers.
        // Copy over current values.
        int numBuffersToCopy = oldBufferCount;
        if (wasFull == NO)
        {
            numBuffersToCopy = oldHeadIndex + 1;
        }
        
        UInt32 numBuffersToDrop = 0;
        if (numBuffersToCopy > newBufferCount)
        {
            numBuffersToDrop = numBuffersToCopy - newBufferCount;
            numBuffersToCopy = newBufferCount;
        }
        
        for (int i = 0; i < newBufferCount; i++)
        {
            if (i < numBuffersToCopy)
            {
                newCircularQueueOfBuffers[i] = recordState.circularQueueOfBuffers[(oldTailIndex + numBuffersToDrop + i) % oldBufferCount];
                newHeadIndex++;
            }
            else
            {
                newCircularQueueOfBuffers[i] = NULL;
            }
        }
        
        // De-allocate the buffers that were dropped.
        for (int i = 0; i < numBuffersToDrop; i++)
        {
            int index = (oldTailIndex + i) % oldBufferCount;
            AudioQueueFreeBuffer(recordState.queue, recordState.circularQueueOfBuffers[index]);
            recordState.circularQueueOfBuffers[index] = NULL;
        }
    }
    
    // Release the memory for the old queue of buffers.
    if (recordState.circularQueueOfBuffers != NULL)
    {
        free(recordState.circularQueueOfBuffers);
    }
    // Set the new queue to be the newly allocated queue.
    recordState.circularQueueOfBuffers = newCircularQueueOfBuffers;
    recordState.circularQueueOfBuffersHeadIndex = newBufferCount > 0 ? newHeadIndex % newBufferCount : -1;
    recordState.circularQueueBufferCount = newBufferCount;
    recordState.isCircularQueueIsFull = (newHeadIndex + 1 >= newBufferCount);
}

@end
