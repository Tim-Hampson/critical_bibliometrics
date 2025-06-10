library(tidyverse)
library(openalexR)
library(writexl)

# Add your email for faster access to the API
options(openalexR.mailto = "myemail@provider.com")


df <- oa_fetch(
  entity = "works",
  title.search = c("English medium instruction"),
  per_page = 200,
  verbose  = TRUE
)

refs_df <- df %>% 
  # keep only the work’s ID and its list of references
  select(work_id = id, referenced_works) %>% 
  
  # unnest that list‐column so each URL becomes its own row
  unnest_longer(referenced_works) %>% 
  
  # drop any NA entries
  filter(!is.na(referenced_works)) %>% 
  
  # optionally strip off the URL prefix so you just have the OpenAlex ID
  mutate(
    referenced_id = str_remove(referenced_works, "https://openalex.org/")
  ) %>% 
  
  # keep only the columns you want
  select(work_id, referenced_id)

citation_df <-refs_df %>% 
  group_by(referenced_id) %>% 
  summarise(in_field_citations = n()) %>% 
  arrange(desc(in_field_citations))

citation_summary_df <- citation_df %>%
  group_by(in_field_citations) %>%
  summarise(frequency = n()) %>%
  arrange(desc(frequency))

  
  # Get the list of high-citation referenced IDs
  top_cited_ids <- citation_df %>%
    filter(in_field_citations > 50) %>%
    arrange(desc(in_field_citations)) %>%
    pull(referenced_id)
  
  # Fetch metadata for those papers
  top_cited_metadata <- oa_fetch(
    entity     = "works",
    identifier = top_cited_ids,
    verbose    = TRUE
  )
  
  joined_df <- top_cited_metadata%>%
    mutate(id = str_remove(id, "https://openalex.org/")) %>%
    left_join(citation_df, by = c("id" = "referenced_id"))%>%
    select(
      id,
      type,
      display_name,
      so,
      doi,
      publication_year,
      cited_by_count,
      in_field_citations
    )%>%
    mutate(relatedness_ratio = in_field_citations / cited_by_count)%>%
    arrange(desc(in_field_citations))
  
  write_xlsx(joined_df, "influential_papers.xlsx")
  
  
  
  