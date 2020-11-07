# MaterialLawCausal
The code for the paper "Data-driven discovery of interpretable causal relations for deep learning material laws with uncertainty quantification"

# Introduction

This is the code for the proposed causal discovery algorithm, including Algorithms 1 and 2 in the paper. 
 Part of the code origins from the code in the paper "Causal Discovery from Heterogeneous/Nonstationary Data with Independent Changes" by Biwei Huang et al. Their codes are  publically available at https://github.com/Biwei-Huang/Causal-Discovery-from-Nonstationary-Heterogeneous-Data. 

## Requirements
Software required: Matlab_R2020b; Jupyter Notebook, webgraphviz

## Usage
We provide two examples: Example1.m and Example2.m. 

Example1.m provides one example to demonstrate how to infer the causal graph from one training experiment. 

Example2.m provides one example to demonstrate how to infer the causal graph from 50 training experiments in our traction-separation numerical study. 

## Potential Error
If you meet some error about matrix computing on running the code, remember to adjust the hyperparameter like Width (recommend using Width = 1, 20, 30 etc). ALWAYS PUT THE NONSTATIONARY VARIABLE OR INPUT AS THE FIRST NODE IN THE DLABEL

## Contributing
Pull requests are welcome. You can use this algorithm to run your own dataset. 

## CITATION
If you use this code, please cite the following paper:

1. Sun X, Bahmani B, Vlassis N, Sun W, Xu, Y, Data-driven discovery of interpretable causal relations for deep learning material laws with uncertainty quantification. 
