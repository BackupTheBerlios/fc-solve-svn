#include <malloc.h>

#include "config.h"

#include "alloc.h"

#define ALLOCED_SIZE (0x10000 - 0x200)

fcs_compact_allocator_t * 
    freecell_solver_compact_allocator_new(void)
{
    fcs_compact_allocator_t * allocator;


    allocator = (fcs_compact_allocator_t *)malloc(sizeof(*allocator));
    allocator->max_num_packs = IA_STATE_PACKS_GROW_BY;
    allocator->packs = (char * *)malloc(sizeof(allocator->packs[0]) * allocator->max_num_packs);
    allocator->num_packs = 1;
    allocator->max_ptr = 
        (allocator->ptr = 
        allocator->rollback_ptr = 
        allocator->packs[0] = 
        malloc(ALLOCED_SIZE))
            + ALLOCED_SIZE;
    
    return allocator;
}

char * 
    freecell_solver_compact_allocator_alloc(
        fcs_compact_allocator_t * allocator,
        int how_much
            )
{
    if (allocator->max_ptr - allocator->ptr < how_much)
    {
        /* Allocate a new pack */
        if (allocator->num_packs == allocator->max_num_packs)
        {
            allocator->max_num_packs += IA_STATE_PACKS_GROW_BY;
            allocator->packs = (char * *)realloc(allocator->packs, sizeof(allocator->packs[0]) * allocator->max_num_packs);
        }
        
        allocator->max_ptr = 
            (allocator->ptr = 
            allocator->rollback_ptr = 
            allocator->packs[allocator->num_packs++] = 
            malloc(ALLOCED_SIZE))
                + ALLOCED_SIZE;
    }
    allocator->rollback_ptr = allocator->ptr;
    allocator->ptr += (how_much+(4-(how_much&0x3)));
    return allocator->rollback_ptr;
}

void freecell_solver_compact_allocator_release(fcs_compact_allocator_t * allocator)
{
    allocator->ptr = allocator->rollback_ptr;
}

void freecell_solver_compact_allocator_finish(fcs_compact_allocator_t * allocator)
{
    int a;
    for(a=0;a<allocator->num_packs;a++)
    {
        free(allocator->packs[a]);
    }
    free(allocator->packs);
    free(allocator);
}

void freecell_solver_compact_allocator_foreach(
    fcs_compact_allocator_t * allocator,
    int data_width,
    void (*ptr_function)(void *, void *),
    void * context
        )
{
    int pack;
    char * ptr, * max_ptr;
    for(pack=0;pack<allocator->num_packs-1;pack++)
    {
        ptr = allocator->packs[pack];
        max_ptr = ptr + ALLOCED_SIZE - data_width;
        while (ptr <= max_ptr)
        {
            ptr_function(ptr, context);
            ptr += data_width;
        }
    }
    /* Run the callback on the last pack */
    ptr = allocator->packs[pack];
    max_ptr = allocator->rollback_ptr;
    while (ptr <= max_ptr)
    {
        ptr_function(ptr, context);
        ptr += data_width;
    }
}
        


