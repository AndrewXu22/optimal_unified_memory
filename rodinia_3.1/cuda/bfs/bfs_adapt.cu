/***********************************************************************************
  Implementing Breadth first search on CUDA using algorithm given in HiPC'07
  paper "Accelerating Large Graph Algorithms on the GPU using CUDA"

  Copyright (c) 2008 International Institute of Information Technology - Hyderabad. 
  All rights reserved.

  Permission to use, copy, modify and distribute this software and its documentation for 
  educational purpose is hereby granted without fee, provided that the above copyright 
  notice and this permission notice appear in all copies of this software and that you do 
  not sell the software.

  THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY OF ANY KIND,EXPRESS, IMPLIED OR 
  OTHERWISE.

  Created by Pawan Harish.
 ************************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <cuda.h>
#include <adapter.h>



#define MAX_THREADS_PER_BLOCK 512

int no_of_nodes;
int edge_list_size;
FILE *fp;

//Structure to hold a node information
struct Node
{
	int starting;
	int no_of_edges;
};

#include "kernel.cu"
#include "kernel2.cu"

void BFSGraph(int argc, char** argv);

////////////////////////////////////////////////////////////////////////////////
// Main Program
////////////////////////////////////////////////////////////////////////////////
int main( int argc, char** argv) 
{
	no_of_nodes=0;
	edge_list_size=0;
	BFSGraph( argc, argv);
}

void Usage(int argc, char**argv){

fprintf(stderr,"Usage: %s <input_file>\n", argv[0]);

}
////////////////////////////////////////////////////////////////////////////////
//Apply BFS on a Graph using CUDA
////////////////////////////////////////////////////////////////////////////////
void BFSGraph( int argc, char** argv) 
{

    char *input_f;
	if(argc!=2){
	Usage(argc, argv);
	exit(0);
	}
	
	input_f = argv[1];
	printf("Reading File\n");
	//Read in Graph from a file
	fp = fopen(input_f,"r");
	if(!fp)
	{
		printf("Error Reading graph file\n");
		return;
	}

	int source = 0;

	fscanf(fp,"%d",&no_of_nodes);

	int num_of_blocks = 1;
	int num_of_threads_per_block = no_of_nodes;

	//Make execution Parameters according to the number of nodes
	//Distribute threads across multiple Blocks if necessary
	if(no_of_nodes>MAX_THREADS_PER_BLOCK)
	{
		num_of_blocks = (int)ceil(no_of_nodes/(double)MAX_THREADS_PER_BLOCK); 
		num_of_threads_per_block = MAX_THREADS_PER_BLOCK; 
	}

	// allocate host memory
                printf("alloc h_graph_nodes\n");
#if adv1==0
	Node* h_graph_nodes = (Node*) malloc(sizeof(Node)*no_of_nodes);
#else
	Node* h_graph_nodes = (Node*) xplacer_malloc(sizeof(Node)*no_of_nodes, Managed);
#endif
                printf("alloc h_graph_mask\n");
#if adv2==0
	bool *h_graph_mask = (bool*) malloc(sizeof(bool)*no_of_nodes);
#else
	bool *h_graph_mask = (bool*) xplacer_malloc(sizeof(bool)*no_of_nodes, Managed);
#endif
                printf("alloc h_updating_graph_mask\n");
#if adv3==0
	bool *h_updating_graph_mask = (bool*) malloc(sizeof(bool)*no_of_nodes);
#else
	bool *h_updating_graph_mask = (bool*) xplacer_malloc(sizeof(bool)*no_of_nodes, Managed);
#endif
                printf("alloc h_graph_visited\n");
#if adv4==0
	bool *h_graph_visited = (bool*) malloc(sizeof(bool)*no_of_nodes);
#else
	bool *h_graph_visited = (bool*) xplacer_malloc(sizeof(bool)*no_of_nodes, Managed);
#endif

	int start, edgeno;   
	// initalize the memory
	for( unsigned int i = 0; i < no_of_nodes; i++) 
	{
		fscanf(fp,"%d %d",&start,&edgeno);
		h_graph_nodes[i].starting = start;
		h_graph_nodes[i].no_of_edges = edgeno;
		h_graph_mask[i]=false;
		h_updating_graph_mask[i]=false;
		h_graph_visited[i]=false;
	}

	//read the source node from the file
	fscanf(fp,"%d",&source);
	source=0;

	//set the source node as true in the mask
	h_graph_mask[source]=true;
	h_graph_visited[source]=true;

	fscanf(fp,"%d",&edge_list_size);

	int id,cost;
                printf("alloc h_graph_edges\n");
#if adv5 == 0
	int* h_graph_edges = (int*) malloc(sizeof(int)*edge_list_size);
#else
	int* h_graph_edges = (int*) xplacer_malloc(sizeof(int)*edge_list_size, Managed);
#endif
	for(int i=0; i < edge_list_size ; i++)
	{
		fscanf(fp,"%d",&id);
		fscanf(fp,"%d",&cost);
		h_graph_edges[i] = id;
	}

	if(fp)
		fclose(fp);    

	printf("Read File\n");

	//Copy the Node list to device memory
	Node* d_graph_nodes;
#if adv1 == 0
	d_graph_nodes = (Node*)xplacer_malloc(sizeof(Node)*no_of_nodes,GPU) ;
	xplacer_memcpy( (void**)&d_graph_nodes, h_graph_nodes, sizeof(Node)*no_of_nodes, cudaMemcpyHostToDevice,false) ;
#else
	xplacer_memcpy( (void**)&d_graph_nodes, h_graph_nodes, sizeof(Node)*no_of_nodes, cudaMemcpyHostToDevice,true) ;
#endif

	//Copy the Edge List to device Memory
	int* d_graph_edges;
#if adv5 == 0
	d_graph_edges = (int*)xplacer_malloc( sizeof(int)*edge_list_size,GPU) ;
	xplacer_memcpy( (void**)&d_graph_edges, h_graph_edges, sizeof(int)*edge_list_size, cudaMemcpyHostToDevice,false) ;
#else
	xplacer_memcpy( (void**)&d_graph_edges, h_graph_edges, sizeof(int)*edge_list_size, cudaMemcpyHostToDevice,true) ;
#endif

	//Copy the Mask to device memory
	bool* d_graph_mask;
#if adv2 == 0 
	d_graph_mask = (bool*)xplacer_malloc( sizeof(bool)*no_of_nodes,GPU) ;
	xplacer_memcpy( (void**)&d_graph_mask, h_graph_mask, sizeof(bool)*no_of_nodes, cudaMemcpyHostToDevice,false) ;
#else
	xplacer_memcpy( (void**)&d_graph_mask, h_graph_mask, sizeof(bool)*no_of_nodes, cudaMemcpyHostToDevice,true) ;
#endif

	bool* d_updating_graph_mask;
#if adv3 == 0 
	d_updating_graph_mask = (bool*)xplacer_malloc( sizeof(bool)*no_of_nodes,GPU) ;
	xplacer_memcpy( (void**)&d_updating_graph_mask, h_updating_graph_mask, sizeof(bool)*no_of_nodes, cudaMemcpyHostToDevice,false) ;
#else
	xplacer_memcpy( (void**)&d_updating_graph_mask, h_updating_graph_mask, sizeof(bool)*no_of_nodes, cudaMemcpyHostToDevice,true) ;
#endif

	//Copy the Visited nodes array to device memory
	bool* d_graph_visited;
#if adv4 == 0
	d_graph_visited = (bool*)xplacer_malloc( sizeof(bool)*no_of_nodes,GPU) ;
	xplacer_memcpy( (void**)&d_graph_visited, h_graph_visited, sizeof(bool)*no_of_nodes, cudaMemcpyHostToDevice,false) ;
#else
	xplacer_memcpy( (void**)&d_graph_visited, h_graph_visited, sizeof(bool)*no_of_nodes, cudaMemcpyHostToDevice,true) ;
#endif

	// allocate mem for the result on host side
#if adv6==0
	int* h_cost = (int*) malloc( sizeof(int)*no_of_nodes);
#else
	int* h_cost = (int*) xplacer_malloc( sizeof(int)*no_of_nodes, Managed);
#endif
	for(int i=0;i<no_of_nodes;i++)
		h_cost[i]=-1;
	h_cost[source]=0;
	
	// allocate device memory for result
	int* d_cost;
#if adv6==0
	d_cost = (int*)xplacer_malloc( sizeof(int)*no_of_nodes,Managed);
	xplacer_memcpy( (void**)&d_cost, h_cost, sizeof(int)*no_of_nodes, cudaMemcpyHostToDevice,false) ;
#else
	xplacer_memcpy( (void**)&d_cost, h_cost, sizeof(int)*no_of_nodes, cudaMemcpyHostToDevice,true) ;
#endif

	//make a bool to check if the execution is over
	bool *d_over;
	cudaMalloc( (void**) &d_over, sizeof(bool));

	printf("Copied Everything to GPU memory\n");

	// setup execution parameters
	dim3  grid( num_of_blocks, 1, 1);
	dim3  threads( num_of_threads_per_block, 1, 1);

	int k=0;
	printf("Start traversing the tree\n");

#if adv1==2
	cudaMemAdvise(h_graph_nodes,sizeof(Node)*no_of_nodes, cudaMemAdviseSetReadMostly, 0);
#elif adv1==3
	cudaMemAdvise(h_graph_nodes,sizeof(Node)*no_of_nodes, cudaMemAdviseSetPreferredLocation, 0);
#elif adv1==4
	cudaMemAdvise(h_graph_nodes,sizeof(Node)*no_of_nodes, cudaMemAdviseSetAccessedBy, 0);
#elif adv1==5
	cudaMemAdvise(h_graph_nodes,sizeof(Node)*no_of_nodes, cudaMemAdviseSetPreferredLocation, cudaCpuDeviceId);
#elif adv1==6
	cudaMemAdvise(h_graph_nodes,sizeof(Node)*no_of_nodes, cudaMemAdviseSetAccessedBy, cudaCpuDeviceId);
#endif

#if adv2==2
	cudaMemAdvise(h_graph_mask,sizeof(bool)*no_of_nodes, cudaMemAdviseSetReadMostly, 0);
#elif adv2==3
	cudaMemAdvise(h_graph_mask,sizeof(bool)*no_of_nodes, cudaMemAdviseSetPreferredLocation, 0);
#elif adv2==4
	cudaMemAdvise(h_graph_mask,sizeof(bool)*no_of_nodes, cudaMemAdviseSetAccessedBy, 0);
#elif adv2==5
	cudaMemAdvise(h_graph_mask,sizeof(bool)*no_of_nodes, cudaMemAdviseSetPreferredLocation, cudaCpuDeviceId);
#elif adv2==6
	cudaMemAdvise(h_graph_mask,sizeof(bool)*no_of_nodes, cudaMemAdviseSetAccessedBy, cudaCpuDeviceId);
#endif

#if adv3==2
	cudaMemAdvise(h_updating_graph_mask,sizeof(bool)*no_of_nodes, cudaMemAdviseSetReadMostly, 0);
#elif adv3==3
	cudaMemAdvise(h_updating_graph_mask,sizeof(bool)*no_of_nodes, cudaMemAdviseSetPreferredLocation, 0);
#elif adv3==4
	cudaMemAdvise(h_updating_graph_mask,sizeof(bool)*no_of_nodes, cudaMemAdviseSetAccessedBy, 0);
#elif adv3==5
	cudaMemAdvise(h_updating_graph_mask,sizeof(bool)*no_of_nodes, cudaMemAdviseSetPreferredLocation, cudaCpuDeviceId);
#elif adv3==6
	cudaMemAdvise(h_updating_graph_mask,sizeof(bool)*no_of_nodes, cudaMemAdviseSetAccessedBy, cudaCpuDeviceId);
#endif

#if adv4==2
	cudaMemAdvise(h_graph_visited,sizeof(bool)*no_of_nodes, cudaMemAdviseSetReadMostly, 0);
#elif adv4==3
	cudaMemAdvise(h_graph_visited,sizeof(bool)*no_of_nodes, cudaMemAdviseSetPreferredLocation, 0);
#elif adv4==4
	cudaMemAdvise(h_graph_visited,sizeof(bool)*no_of_nodes, cudaMemAdviseSetAccessedBy, 0);
#elif adv4==5
	cudaMemAdvise(h_graph_visited,sizeof(bool)*no_of_nodes, cudaMemAdviseSetPreferredLocation, cudaCpuDeviceId);
#elif adv4==6
	cudaMemAdvise(h_graph_visited,sizeof(bool)*no_of_nodes, cudaMemAdviseSetAccessedBy, cudaCpuDeviceId);
#endif

#if adv5==2
	cudaMemAdvise(h_graph_edges,sizeof(int)*no_of_nodes, cudaMemAdviseSetReadMostly, 0);
#elif adv5==3
	cudaMemAdvise(h_graph_edges,sizeof(int)*no_of_nodes, cudaMemAdviseSetPreferredLocation, 0);
#elif adv5==4
	cudaMemAdvise(h_graph_edges,sizeof(int)*no_of_nodes, cudaMemAdviseSetAccessedBy, 0);
#elif adv5==5
	cudaMemAdvise(h_graph_edges,sizeof(int)*no_of_nodes, cudaMemAdviseSetPreferredLocation, cudaCpuDeviceId);
#elif adv5==6
	cudaMemAdvise(h_graph_edges,sizeof(int)*no_of_nodes, cudaMemAdviseSetAccessedBy, cudaCpuDeviceId);
#endif

#if adv6==2
	cudaMemAdvise(h_cost,sizeof(int)*no_of_nodes, cudaMemAdviseSetReadMostly, 0);
#elif adv6==3
	cudaMemAdvise(h_cost,sizeof(int)*no_of_nodes, cudaMemAdviseSetPreferredLocation, 0);
#elif adv6==4
	cudaMemAdvise(h_cost,sizeof(int)*no_of_nodes, cudaMemAdviseSetAccessedBy, 0);
#elif adv6==5
	cudaMemAdvise(h_cost,sizeof(int)*no_of_nodes, cudaMemAdviseSetPreferredLocation, cudaCpuDeviceId);
#elif adv6==6
	cudaMemAdvise(h_cost,sizeof(int)*no_of_nodes, cudaMemAdviseSetAccessedBy, cudaCpuDeviceId);
#endif
//	setAdvise = cudaMemAdviseSetPreferredLocation;

	bool stop;
	//Call the Kernel untill all the elements of Frontier are not false
	do
	{
		//if no thread changes this value then the loop stops
		stop=false;
		cudaMemcpy( d_over, &stop, sizeof(bool), cudaMemcpyHostToDevice) ;
		

		Kernel<<< grid, threads, 0 >>>( d_graph_nodes, d_graph_edges, d_graph_mask, d_updating_graph_mask, d_graph_visited, d_cost, no_of_nodes);
		// check if kernel execution generated and error
		

		Kernel2<<< grid, threads, 0 >>>( d_graph_mask, d_updating_graph_mask, d_graph_visited, d_over, no_of_nodes);
		// check if kernel execution generated and error
		
		cudaMemcpy( &stop, d_over, sizeof(bool), cudaMemcpyDeviceToHost) ;
		k++;
  cudaDeviceSynchronize();

	}
	while(stop);



	printf("Kernel Executed %d times\n",k);

	// copy result from device to host
//	xplacer_memcpy( h_cost, d_cost, sizeof(int)*no_of_nodes, cudaMemcpyDeviceToHost,true) ;

	//Store the result into a file
	FILE *fpo = fopen("result.txt","w");
	for(int i=0;i<no_of_nodes;i++)
		fprintf(fpo,"%d) cost:%d\n",i,h_cost[i]);
	fclose(fpo);
	printf("Result stored in result.txt\n");


	// cleanup memory
#if adv1 == 0
	xplacer_free( h_graph_nodes, CPU);
	xplacer_free(d_graph_nodes,GPU);
#else
	xplacer_free( h_graph_nodes, Managed);
#endif
#if adv5 == 0
	xplacer_free( h_graph_edges, CPU);
	xplacer_free(d_graph_edges,GPU);
#else
	xplacer_free( h_graph_edges, Managed);
#endif
#if adv2 == 0
	xplacer_free( h_graph_mask, CPU);
	xplacer_free(d_graph_mask,GPU);
#else
	xplacer_free( h_graph_mask, Managed);
#endif
#if adv3 == 0
	xplacer_free( h_updating_graph_mask, CPU);
	xplacer_free(d_updating_graph_mask,GPU);
#else
	xplacer_free( h_updating_graph_mask, Managed);
#endif
#if adv4 == 0
	xplacer_free( h_graph_visited, CPU);
	xplacer_free(d_graph_visited,GPU);
#else
	xplacer_free( h_graph_visited, Managed);
#endif
#if adv6 == 0
	xplacer_free( h_cost, CPU);
	xplacer_free(d_cost,GPU);
#else
	xplacer_free( h_cost, Managed);
#endif
}
