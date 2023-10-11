#include "warp.h"
#include "scan.h"

#define THRUST_IGNORE_CUB_VERSION_CHECK

#include <cub/device/device_scan.cuh>

template<typename T>
void scan_device(const T* values_in, T* values_out, int n, bool inclusive)
{
    ContextGuard guard(cuda_context_get_current());

    cudaStream_t stream = static_cast<cudaStream_t>(cuda_stream_get_current());

    // compute temporary memory required
	size_t scan_temp_size;
    if (inclusive) {
        check_cuda(cub::DeviceScan::InclusiveSum(NULL, scan_temp_size, values_in, values_out, n));
    } else {
        check_cuda(cub::DeviceScan::ExclusiveSum(NULL, scan_temp_size, values_in, values_out, n));
    }

    void* temp_buffer = alloc_temp_device(WP_CURRENT_CONTEXT, scan_temp_size);

    // scan
    if (inclusive) {
        check_cuda(cub::DeviceScan::InclusiveSum(temp_buffer, scan_temp_size, values_in, values_out, n, stream));
    } else {
        check_cuda(cub::DeviceScan::ExclusiveSum(temp_buffer, scan_temp_size, values_in, values_out, n, stream));
    }

    free_temp_device(WP_CURRENT_CONTEXT, temp_buffer);
}

template void scan_device(const int*, int*, int, bool);
template void scan_device(const float*, float*, int, bool);
