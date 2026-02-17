// MLT Framework C Bridging Header
// This header exposes MLT's C API to Swift

#ifndef MLT_BRIDGE_H
#define MLT_BRIDGE_H

// Note: MLT headers are not included in Shotcut.app bundle
// We'll need to either:
// 1. Install MLT via Homebrew: brew install mlt
// 2. Or manually link against the dylib and declare functions ourselves

// For now, we'll declare the essential MLT functions manually
// Reference: https://github.com/mltframework/mlt/tree/master/src/framework

#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

// ============================================================================
// MLT Core Types (Opaque Pointers)
// ============================================================================

typedef void* mlt_repository;
typedef void* mlt_profile;
typedef void* mlt_producer;
typedef void* mlt_consumer;
typedef void* mlt_filter;
typedef void* mlt_transition;
typedef void* mlt_frame;
typedef void* mlt_properties;
typedef void* mlt_playlist;
typedef void* mlt_tractor;
typedef void* mlt_service;

// ============================================================================
// MLT Profile Structure
// ============================================================================

struct mlt_profile_s {
    char *description;
    int frame_rate_num;
    int frame_rate_den;
    int width;
    int height;
    int progressive;
    int sample_aspect_num;
    int sample_aspect_den;
    int display_aspect_num;
    int display_aspect_den;
    int colorspace;
};

typedef struct mlt_profile_s* mlt_profile;

// ============================================================================
// MLT Repository Functions
// ============================================================================

mlt_repository mlt_repository_init(const char *directory);
void* mlt_repository_metadata(mlt_repository repo, const char *type, const char *service);
void* mlt_repository_filters(mlt_repository repo);
void* mlt_repository_transitions(mlt_repository repo);
void* mlt_repository_producers(mlt_repository repo);

// ============================================================================
// MLT Factory Functions
// ============================================================================

mlt_repository mlt_factory_init(const char *directory);
mlt_profile mlt_profile_init(const char *name);
mlt_producer mlt_factory_producer(mlt_profile profile, const char *id, const void *service);
mlt_filter mlt_factory_filter(mlt_profile profile, const char *id, const void *service);
mlt_transition mlt_factory_transition(mlt_profile profile, const char *id, const void *service);
mlt_consumer mlt_factory_consumer(mlt_profile profile, const char *id, const void *service);
void mlt_factory_close(void);

// ============================================================================
// MLT Profile Functions
// ============================================================================

mlt_profile mlt_profile_clone(mlt_profile profile);
void mlt_profile_close(mlt_profile profile);

// ============================================================================
// MLT Producer Functions
// ============================================================================

int mlt_producer_attach(mlt_producer producer, mlt_filter filter);
mlt_frame mlt_producer_get_frame(mlt_producer producer);
mlt_properties mlt_producer_properties(mlt_producer producer);
void mlt_producer_close(mlt_producer producer);

// ============================================================================
// MLT Consumer Functions
// ============================================================================

int mlt_consumer_connect(mlt_consumer consumer, mlt_service service);
int mlt_consumer_start(mlt_consumer consumer);
int mlt_consumer_stop(mlt_consumer consumer);
void mlt_consumer_close(mlt_consumer consumer);
mlt_properties mlt_consumer_properties(mlt_consumer consumer);

// ============================================================================
// MLT Filter Functions
// ============================================================================

int mlt_filter_connect(mlt_filter filter, mlt_service service, int index);
mlt_properties mlt_filter_properties(mlt_filter filter);
void mlt_filter_close(mlt_filter filter);

// ============================================================================
// MLT Transition Functions
// ============================================================================

int mlt_transition_connect(mlt_transition transition, mlt_service a, mlt_service b);
mlt_properties mlt_transition_properties(mlt_transition transition);
void mlt_transition_close(mlt_transition transition);

// ============================================================================
// MLT Properties Functions
// ============================================================================

int mlt_properties_set(mlt_properties properties, const char *name, const char *value);
int mlt_properties_set_int(mlt_properties properties, const char *name, int value);
int mlt_properties_set_double(mlt_properties properties, const char *name, double value);
char* mlt_properties_get(mlt_properties properties, const char *name);
int mlt_properties_get_int(mlt_properties properties, const char *name);
double mlt_properties_get_double(mlt_properties properties, const char *name);

// ============================================================================
// MLT Playlist Functions
// ============================================================================

mlt_playlist mlt_playlist_init(void);
int mlt_playlist_append(mlt_playlist playlist, mlt_producer producer);
void mlt_playlist_close(mlt_playlist playlist);

// ============================================================================
// MLT Service Functions (Base Type)
// ============================================================================

mlt_service mlt_producer_service(mlt_producer producer);
mlt_service mlt_filter_service(mlt_filter filter);
mlt_service mlt_transition_service(mlt_transition transition);
mlt_service mlt_consumer_service(mlt_consumer consumer);

#ifdef __cplusplus
}
#endif

#endif // MLT_BRIDGE_H
