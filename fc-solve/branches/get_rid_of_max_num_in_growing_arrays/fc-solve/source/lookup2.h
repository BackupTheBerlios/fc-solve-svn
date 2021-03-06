#ifndef FC_SOLVE__LOOKUP2_H
#define FC_SOLVE__LOOKUP2_H

typedef  unsigned long  int  ub4;   /* unsigned 4-byte quantities */
typedef  unsigned       char ub1;

ub4 fc_solve_lookup2_hash_function(
    register ub1 *k,        /* the key */
    register ub4  length,   /* the length of the key */
    register ub4  initval    /* the previous hash, or an arbitrary value */
        );

#endif /* FC_SOLVE__LOOKUP2_H */
