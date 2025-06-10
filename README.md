# critical_bibliometrics

As part of my PhD thesis, I have been working on scripts to conduct critical bibliometrics. This is a **methodology** that takes a critical quantitative approach to analysing authorship and citation patterns to answer:  
> Who gets to speak in academia, and who is listened to?

Bibliometric techniques are **surprisingly** achievable and fast in R, especially with access to the `openalexR` library. I’ll be uploading scripts to this **repo** to help others explore citation patterns and influence through a more critical lens.

## 01_influential_papers

This script will:  
1. Conduct a search for all papers on a topic.  
2. Extract all citations from those papers and calculate the number of in-field citations.  
3. Calculate citation ratio: the number of in-field citations divided by global citations.

The goal then is to produce a list of 'influential' papers in a field. This is done by filtering to provide a list of all papers that have been cited more than x times in a field. 50 is probably a good starting point for most fields.

It is also possible to filter by citation ratio, as results with a very low citation ratio are likely in the list because they are generally often cited rather than because they are often cited by a particular field. It is also completely acceptable to not filter based on this. I would **recommend** against setting this filter much **above** 0.15.
