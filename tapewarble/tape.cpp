#include "usermodfx.h"

static float lfo_phase = 0.0f;
static float mod_depth = 0.5f; // Range: 0.0 to 1.0
static float mod_rate = 1.0f;  // 1 Hz at middle position

// called upon instantiation of effect, use for initializations 
// see inc/userprg.h for possible values of platform and api
void MODFX_INIT(uint32_t platform, uint32_t api) {
}

float lfo(float phase) {
    return sinf(phase * 2 * M_PI);
}

void MODFX_PARAM(uint8_t index, int32_t value) {
    const float param = value / 100.0f; // Range: 0.0 to 1.0

    switch (index) {
        case k_user_modfx_param_time: // Time knob for modulation rate
            mod_rate = param; 
            break;
        case k_user_modfx_param_depth: // Depth knob for modulation depth
            mod_depth = param; // Quarter octave at max
            break;
        default:
            break;
    }
}

// Linear interpolation function
float linearInterpolate(float a, float b, float fraction) {
    return a + fraction * (b - a);
}

void MODFX_PROCESS(const float *main_xn, float *main_yn,
                   const float *sub_xn,  float *sub_yn,
                   uint32_t frames) {

    static float playhead = 0; // Position in the input buffer
    float rate = 1.0 + mod_depth; // Adjust this for the desired pitch shift

    for (uint32_t i = 0; i < frames; i++) {
        // Calculate the indices of the two samples we are interpolating between
        int sampleIndex1 = (int)playhead;
        int sampleIndex2 = sampleIndex1 + 1;
        if (sampleIndex2 >= frames) sampleIndex2 -= frames; // Wrap around if needed

        // Calculate the fractional part of the playhead position
        float fraction = playhead - (float)sampleIndex1;

        // Perform linear interpolation for main and sub channels
        main_yn[i] = linearInterpolate(main_xn[sampleIndex1], main_xn[sampleIndex2], fraction);
        sub_yn[i] = linearInterpolate(sub_xn[sampleIndex1], sub_xn[sampleIndex2], fraction);

        // Move the playhead
        playhead += rate;
        if (playhead >= frames) playhead -= frames; // Loop back if end of buffer is reached
    }
}





