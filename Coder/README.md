# Coder Agent

A simple code assistant agent.

It uses the Gemini gemini-2.0-flash model to implement a simple 
code-writing agent that emits full code files as artifacts.

The code generated is in the Dart language.

You will an API key for Gemini set in the following environment variable :-

GEMINI_API_KEY

To run the agent simply do a 'dart pub get' followed by running
the coder.dart file i.e. 'dart run coder.dart'

The agent will start on `http://localhost:41241`.

See the comment at the top of the containerfile for instructions on how
to build and run the agent as a podman container.