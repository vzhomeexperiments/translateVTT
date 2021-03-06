# Getting Youtube transcripts programmatically https://github.com/jdepoix/youtube-transcript-api

#install -> run in the terminal
pip install youtube_transcript_api
pip install pandas

# this does not work:
transcript = YouTubeTranscriptApi.get_transcripts(video_ids = "wyrbGSX3jwU")

# this works own video
export = YouTubeTranscriptApi.get_transcript(video_id = "wyrbGSX3jwU")

# this is not my video (also works)
exp2 = YouTubeTranscriptApi.get_transcript(video_id = "Vyau3VUVVtI")

print(export)

# determine object type (list)
type(export)

# save list to csv
import pandas as pd

# convert to dataframe
df = pd.DataFrame(export)
# write to csv file
df.to_csv('filename.csv', index=False)


# convert to dataframe
df2 = pd.DataFrame(exp2)

# write to csv file
df2.to_csv('filename2.csv', index=False)

#transcript_list = YouTubeTranscriptApi.list_transcripts(video_id = "wyrbGSX3jwU", languages=['de', 'en'])

# works on command line interface
youtube_transcript_api "wyrbGSX3jwU"

#### EXAMPLE

# retrieve the available transcripts
transcript_list = YouTubeTranscriptApi.list_transcripts('wyrbGSX3jwU')

print(transcript_list)

# iterate over all available transcripts
for transcript in transcript_list:

    # the Transcript object provides metadata properties
    print(
        transcript.video_id,
        transcript.language,
        transcript.language_code,
        # whether it has been manually created or generated by YouTube
        transcript.is_generated,
        # whether this transcript can be translated or not
        transcript.is_translatable,
        # a list of languages the transcript can be translated to
        transcript.translation_languages,
    )

    # fetch the actual transcript data
    print(transcript.fetch())

    # translating the transcript will return another transcript object
    print(transcript.translate('de').fetch())

# you can also directly filter for the language you are looking for, using the transcript list
transcript = transcript_list.find_transcript(['de', 'en'])  

# or just filter for manually created transcripts  
transcript = transcript_list.find_manually_created_transcript(['de', 'en'])  

# or automatically generated ones  
transcript = transcript_list.find_generated_transcript(['de', 'en'])

# translate
transcript


## Option: translate by youtube api
vidid = "jOKODSnSIQk"

# get all data
transcript_list = YouTubeTranscriptApi.list_transcripts(vidid)

# manually created transcript
transcript = transcript_list.find_manually_created_transcript('en')


## workflow summary that can be used:

# 1. Correct closed captions with Youtube Studio
# 2. Extract as vtt file
# 3. Translate with translateVTT
# 4. Upload back to Youtube


