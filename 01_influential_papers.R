#---- 01. Setup ----
library(tidyverse)
library(openalexR)
library(writexl)

# Add your email for faster access to the API
options(openalexR.mailto = "myemail@provider.com")

#----02. Find papers ----
#Find the initial pool of papers. Change "English medium instruction" for your search term. 
#Please check openalexR documentation for more search options. 
df <- oa_fetch(
  entity = "works",
  title.search = c("English medium instruction"),
  per_page = 200,
  verbose  = TRUE
)

#----03. Get references----
#refs_df is a dataframe of every reference 
refs_df <- df %>% 
  unnest_longer(referenced_works) %>% #Create a list of referenced links 
  filter(!is.na(referenced_works)) %>% #Remove na values. 
  # remove unneeded URL 
  mutate(referenced_id = str_remove(referenced_works, "https://openalex.org/"))%>%
  select(id, referenced_id)

#citation_df contains each referenced paper and it's in field citations
citation_df <-refs_df %>% 
  group_by(referenced_id) %>% 
  summarise(in_field_citations = n()) %>% 
  arrange(desc(in_field_citations))

#We don't *need* to have a summary of how much these papers are cited, but it is interesting. 
citation_summary_df <- citation_df %>%
  group_by(in_field_citations) %>%
  summarise(frequency = n()) %>%
  arrange(desc(frequency))

#---- 04. Make 'influential' papers list ----  
# Create a filtered list of 'influential' papers.
top_cited_ids <- citation_df %>%
  filter(in_field_citations > 50) %>% #Update this number based on your needs
  arrange(desc(in_field_citations)) %>%
  pull(referenced_id)
  # Fetch metadata for those papers
top_cited_metadata <- oa_fetch(
  entity     = "works",
  identifier = top_cited_ids,
  verbose    = TRUE
  )
  #Join the info 
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
  mutate(citation_ratio = in_field_citations / cited_by_count)%>%
  filter(citation_ratio > 0.1)%>% #Comment this out if not needed.
  arrange(desc(in_field_citations))
  
  write_xlsx(joined_df, "influential_papers.xlsx")
  
  
  
  