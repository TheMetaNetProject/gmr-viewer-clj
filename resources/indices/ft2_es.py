# =====================================================================
# Elasticsearch
# ---------------------------------------------------------------------
# Make index for 'lms' key; no index if no lms key is present
# ---------------------------------------------------------------------

def get(m, k, default):
    "Same as dict.get(k[, default]) for java.util.Map objects."
    v = m.get(k)
    return v if v else default

def make_index(ctx):
    "Make flat index from document in ctx.doc."
    doc = ctx['doc']
    if 'lms' in doc and len(doc['lms']) > 0:
        newDoc = dict()
        lms = doc['lms']
        newDoc['id'] = doc['_id']
        if 'perspective' in doc:
            newDoc['perspective'] = doc['perspective']

        # Include sentence
        newDoc['text'] = doc['text']

        for lm in lms:
            # Here lm is actually an instance of java.util.Map (bug in jython?)
            newDoc['score'] = lm['score']
            newDoc['cms']   = [c.split('Metaphor_')[1] for c in get(lm, 'cms', [])]
            newDoc['cxn']   = lm['cxn']

            # Source
            source = lm['source']
            newDoc['source-form']           = source['form']
            newDoc['source-lemma']          = source['lemma']
            newDoc['source-concepts']       = source['concepts']
            newDoc['source-framenames']     = source['framenames']
            newDoc['source-framefamilies']  = source['framefamilies']
            newDoc['source-coreness']       = [m['coreness']
                                               for m in get(source, 'mappings', [])
                                               if 'coreness' in m]

            # Target
            target = lm['target']
            newDoc['target-form']           = target['form']
            newDoc['target-lemma']          = target['lemma']
            newDoc['target-concept']        = target['concept']
            newDoc['target-framenames']     = target['framenames']
            newDoc['target-congroup']       = target['congroup']
            newDoc['target-framefamily']    = target['framefamily']

        return newDoc
    else:
        return None

lms = make_index(ctx)
if lms != None:
    ctx['doc'] = lms
else:
    ctx['ignore'] = True
