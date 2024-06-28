#!/bin/bash

model="phi3:mini"
sources=$(cat)
context="For your context, the following refrence material was extracted from a screen capture tool that may capture an entire screen or just an application window. The text may seem disjointed as the translation from screen shot to text is not aware of seperate windows of conext."
question="Can you breifly summarize what the screenshot text suggests the user(Josh) was doing in two brief sentences?\n\n"
#followup="After the summary, can you provide some advice for the user?\n\n"
followup=""
/Applications/Ollama.app/Contents/Resources/ollama run --verbose $model """'$context' -------------------- Reference material: ------------- $sources ------------------ Please answer the query using the provided information: '$question'---------------------------------------------------------------------------'$followup'"""
