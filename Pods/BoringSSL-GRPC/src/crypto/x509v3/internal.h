/*
 * Written by Dr Stephen N Henson (steve@openssl.org) for the OpenSSL project
 * 2004.
 */
/* ====================================================================
 * Copyright (c) 2004 The OpenSSL Project.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgment:
 *    "This product includes software developed by the OpenSSL Project
 *    for use in the OpenSSL Toolkit. (http://www.OpenSSL.org/)"
 *
 * 4. The names "OpenSSL Toolkit" and "OpenSSL Project" must not be used to
 *    endorse or promote products derived from this software without
 *    prior written permission. For written permission, please contact
 *    licensing@OpenSSL.org.
 *
 * 5. Products derived from this software may not be called "OpenSSL"
 *    nor may "OpenSSL" appear in their names without prior written
 *    permission of the OpenSSL Project.
 *
 * 6. Redistributions of any form whatsoever must retain the following
 *    acknowledgment:
 *    "This product includes software developed by the OpenSSL Project
 *    for use in the OpenSSL Toolkit (http://www.OpenSSL.org/)"
 *
 * THIS SOFTWARE IS PROVIDED BY THE OpenSSL PROJECT ``AS IS'' AND ANY
 * EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE OpenSSL PROJECT OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 * ====================================================================
 *
 * This product includes cryptographic software written by Eric Young
 * (eay@cryptsoft.com).  This product includes software written by Tim
 * Hudson (tjh@cryptsoft.com).
 *
 */

#ifndef OPENSSL_HEADER_X509V3_INTERNAL_H
#define OPENSSL_HEADER_X509V3_INTERNAL_H

#include <openssl_grpc/base.h>

#include <openssl_grpc/conf.h>
#include <openssl_grpc/stack.h>
#include <openssl_grpc/x509v3.h>

#if defined(__cplusplus)
extern "C" {
#endif


// x509v3_bytes_to_hex encodes |len| bytes from |buffer| to hex and returns a
// newly-allocated NUL-terminated string containing the result, or NULL on
// allocation error.
//
// Note this function was historically named |hex_to_string| in OpenSSL, not
// |string_to_hex|.
char *x509v3_bytes_to_hex(const unsigned char *buffer, long len);

// x509v3_hex_string_to_bytes decodes |str| in hex and returns a newly-allocated
// array containing the result, or NULL on error. On success, it sets |*len| to
// the length of the result. Colon separators between bytes in the input are
// allowed and ignored.
//
// Note this function was historically named |string_to_hex| in OpenSSL, not
// |hex_to_string|.
unsigned char *x509v3_hex_to_bytes(const char *str, long *len);

// x509v3_name_cmp returns zero if |name| is equal to |cmp| or begins with |cmp|
// followed by '.'. Otherwise, it returns a non-zero number.
int x509v3_name_cmp(const char *name, const char *cmp);

// x509v3_looks_like_dns_name returns one if |in| looks like a DNS name and zero
// otherwise.
OPENSSL_EXPORT int x509v3_looks_like_dns_name(const unsigned char *in,
                                              size_t len);

// x509v3_cache_extensions fills in a number of fields relating to X.509
// extensions in |x|. It returns one on success and zero if some extensions were
// invalid.
int x509v3_cache_extensions(X509 *x);

// x509v3_a2i_ipadd decodes |ipasc| as an IPv4 or IPv6 address. IPv6 addresses
// use colon-separated syntax while IPv4 addresses use dotted decimal syntax. If
// it decodes an IPv4 address, it writes the result to the first four bytes of
// |ipout| and returns four. If it decodes an IPv6 address, it writes the result
// to all 16 bytes of |ipout| and returns 16. Otherwise, it returns zero.
int x509v3_a2i_ipadd(unsigned char ipout[16], const char *ipasc);

// A |BIT_STRING_BITNAME| is used to contain a list of bit names.
typedef struct {
  int bitnum;
  const char *lname;
  const char *sname;
} BIT_STRING_BITNAME;

// x509V3_add_value_asn1_string appends a |CONF_VALUE| with the specified name
// and value to |*extlist|. if |*extlist| is NULL, it sets |*extlist| to a
// newly-allocated |STACK_OF(CONF_VALUE)| first. It returns one on success and
// zero on error.
int x509V3_add_value_asn1_string(const char *name, const ASN1_STRING *value,
                                 STACK_OF(CONF_VALUE) **extlist);

typedef struct X509_POLICY_DATA_st X509_POLICY_DATA;

DEFINE_STACK_OF(X509_POLICY_DATA)

/* Internal structures */

/*
 * This structure and the field names correspond to the Policy 'node' of
 * RFC 3280. NB this structure contains no pointers to parent or child data:
 * X509_POLICY_NODE contains that. This means that the main policy data can
 * be kept static and cached with the certificate.
 */

struct X509_POLICY_DATA_st {
    unsigned int flags;
    /* Policy OID and qualifiers for this data */
    ASN1_OBJECT *valid_policy;
    STACK_OF(POLICYQUALINFO) *qualifier_set;
    STACK_OF(ASN1_OBJECT) *expected_policy_set;
};

/* X509_POLICY_DATA flags values */

/*
 * This flag indicates the structure has been mapped using a policy mapping
 * extension. If policy mapping is not active its references get deleted.
 */

#define POLICY_DATA_FLAG_MAPPED                 0x1

/*
 * This flag indicates the data doesn't correspond to a policy in Certificate
 * Policies: it has been mapped to any policy.
 */

#define POLICY_DATA_FLAG_MAPPED_ANY             0x2

/* AND with flags to see if any mapping has occurred */

#define POLICY_DATA_FLAG_MAP_MASK               0x3

/* qualifiers are shared and shouldn't be freed */

#define POLICY_DATA_FLAG_SHARED_QUALIFIERS      0x4

/* Parent node is an extra node and should be freed */

#define POLICY_DATA_FLAG_EXTRA_NODE             0x8

/* Corresponding CertificatePolicies is critical */

#define POLICY_DATA_FLAG_CRITICAL               0x10

/* This structure is cached with a certificate */

struct X509_POLICY_CACHE_st {
    /* anyPolicy data or NULL if no anyPolicy */
    X509_POLICY_DATA *anyPolicy;
    /* other policy data */
    STACK_OF(X509_POLICY_DATA) *data;
    /* If InhibitAnyPolicy present this is its value or -1 if absent. */
    long any_skip;
    /*
     * If policyConstraints and requireExplicitPolicy present this is its
     * value or -1 if absent.
     */
    long explicit_skip;
    /*
     * If policyConstraints and policyMapping present this is its value or -1
     * if absent.
     */
    long map_skip;
};

/*
 * #define POLICY_CACHE_FLAG_CRITICAL POLICY_DATA_FLAG_CRITICAL
 */

/* This structure represents the relationship between nodes */

struct X509_POLICY_NODE_st {
    /* node data this refers to */
    const X509_POLICY_DATA *data;
    /* Parent node */
    X509_POLICY_NODE *parent;
    /* Number of child nodes */
    int nchild;
};

struct X509_POLICY_LEVEL_st {
    /* Cert for this level */
    X509 *cert;
    /* nodes at this level */
    STACK_OF(X509_POLICY_NODE) *nodes;
    /* anyPolicy node */
    X509_POLICY_NODE *anyPolicy;
    /* Extra data */
    /*
     * STACK_OF(X509_POLICY_DATA) *extra_data;
     */
    unsigned int flags;
};

struct X509_POLICY_TREE_st {
    /* This is the tree 'level' data */
    X509_POLICY_LEVEL *levels;
    int nlevel;
    /*
     * Extra policy data when additional nodes (not from the certificate) are
     * required.
     */
    STACK_OF(X509_POLICY_DATA) *extra_data;
    /* This is the authority constained policy set */
    STACK_OF(X509_POLICY_NODE) *auth_policies;
    STACK_OF(X509_POLICY_NODE) *user_policies;
    unsigned int flags;
};

/* Set if anyPolicy present in user policies */
#define POLICY_FLAG_ANY_POLICY          0x2

/* Useful macros */

#define node_data_critical(data) ((data)->flags & POLICY_DATA_FLAG_CRITICAL)
#define node_critical(node) node_data_critical((node)->data)

/* Internal functions */

X509_POLICY_DATA *policy_data_new(POLICYINFO *policy, const ASN1_OBJECT *id,
                                  int crit);
void policy_data_free(X509_POLICY_DATA *data);

X509_POLICY_DATA *policy_cache_find_data(const X509_POLICY_CACHE *cache,
                                         const ASN1_OBJECT *id);
int policy_cache_set_mapping(X509 *x, POLICY_MAPPINGS *maps);

STACK_OF(X509_POLICY_NODE) *policy_node_cmp_new(void);

void policy_cache_init(void);

void policy_cache_free(X509_POLICY_CACHE *cache);

X509_POLICY_NODE *level_find_node(const X509_POLICY_LEVEL *level,
                                  const X509_POLICY_NODE *parent,
                                  const ASN1_OBJECT *id);

X509_POLICY_NODE *tree_find_sk(STACK_OF(X509_POLICY_NODE) *sk,
                               const ASN1_OBJECT *id);

X509_POLICY_NODE *level_add_node(X509_POLICY_LEVEL *level,
                                 X509_POLICY_DATA *data,
                                 X509_POLICY_NODE *parent,
                                 X509_POLICY_TREE *tree);
void policy_node_free(X509_POLICY_NODE *node);
int policy_node_match(const X509_POLICY_LEVEL *lvl,
                      const X509_POLICY_NODE *node, const ASN1_OBJECT *oid);

const X509_POLICY_CACHE *policy_cache_set(X509 *x);


#if defined(__cplusplus)
}  /* extern C */
#endif

#endif  /* OPENSSL_HEADER_X509V3_INTERNAL_H */
