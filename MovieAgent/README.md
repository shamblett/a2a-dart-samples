# Movie Info Agent

This agent uses the TMDB API to answer questions about movies. 

It uses the Gemini gemini-2.0-flash model and the TMDB API to answer questions
about movies, actors and directors such as 'Who directed the Matrix' and 'What is the plot of Inception'.

You will need API keys for both Gemini and TMDB set in the following environment variables :-

GEMINI_API_KEY and TMDB_API_KEY 

To run the agent simply do a 'dart pub get' followed by running
the movie_agent.dart file i.e. 'dart run movie_agent.dart'

The agent will start on `http://localhost:41241`.