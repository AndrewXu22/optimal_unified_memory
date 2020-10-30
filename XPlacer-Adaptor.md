XPlacer_Adapter tutorial:

1. Adding header: include adapter.h
    1. Example: https://github.com/AndrewXu22/optimal_unified_memory/blob/master/rodinia_3.1/cuda/bfs/bfs_adapt.cu#L23
2. Replace memory allocation: Replacing new or malloc to xplacer_malloc
    2. xplacer_malloc(size_t s, alloc_type t): the second argument specify the memory you want to allocate.  Options are CPU, GPU, and Managed (unified memory).
    3. Example of original code: [https://github.com/AndrewXu22/optimal_unified_memory/blob/master/rodinia_3.1/cuda/bfs/bfs_adapt.cu#L100](https://github.com/AndrewXu22/optimal_unified_memory/blob/master/rodinia_3.1/cuda/bfs/bfs_adapt.cu#L100)
    4. Example of xplacer_malloc usage: https://github.com/AndrewXu22/optimal_unified_memory/blob/master/rodinia_3.1/cuda/bfs/bfs_adapt.cu#L102
3. Replace memory deallocation: same as allocation
    5. xplacer_free(void* p, alloc_type t): Second argument options are same as allocator
    6. Example of original code: https://github.com/AndrewXu22/optimal_unified_memory/blob/master/rodinia_3.1/cuda/bfs/bfs.cu#L218
    7. Example using xplacer_free: https://github.com/AndrewXu22/optimal_unified_memory/blob/master/rodinia_3.1/cuda/bfs/bfs_adapt.cu#L353
4. Replace memcpy:
    8. xplacer_memcpy(void** dst, void* src, size_t count, cudaMemcpyKind kind, bool isUnified): this is mostly to address cudaMemcpy.  Same arguments as cuda_memcpy is provided but with additional arguments to specify if unified memory is involved.
    9. Example of xplacer_memcpy usage: [https://github.com/AndrewXu22/optimal_unified_memory/blob/master/rodinia_3.1/cuda/bfs/bfs_adapt.cu#L168](https://github.com/AndrewXu22/optimal_unified_memory/blob/master/rodinia_3.1/cuda/bfs/bfs_adapt.cu#L168)
    10. There could be issues using the adapter if the two memory spaces  keep copying back and forth to update each other.
5. Adding advises:
    11. Adapter has some support but I still just use the cuda API to trigger advises
    12. Example https://github.com/AndrewXu22/optimal_unified_memory/blob/master/rodinia_3.1/cuda/bfs/bfs_adapt.cu#L241
