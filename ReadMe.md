# Integrated inimum mean squared error algorithms for combined acoustic echo cancellation and noise reduction
# License
This work is licensed under the [MIT LICENSE](LICENSE.md). By downloading and/or installing this software and associated files on your computing system you agree to use the software under the terms and conditions as specified in the license agreement.

If this code has been useful for you, while the manuscript is under review, please cite the preprint [[1]](#References).

# About
This repository [[2]](#References) contains the MATLAB code associated with [[1]](#References), where an integrated design is followed for the combined problem of acoustic echo cancellation (AEC) and noise reduction (NR) in a general multi-microphone/multi-loudspeaker setup, with possibly linearly dependent miphone and loudspeaker signals. 

This repository provides example codes for the following resulting algorithms:
* MWF: Multi-channel Wiener filter;
* MWF<sub>ext</sub>: Extended multi-channel Wiener filter;
* AEC-NR: AEC preceding NR;
* NR-AEC: NR preceding AEC;
* NR<sub>ext</sub>-AEC-PF: Extended noise reduction (NR<sub>ext</sub>) preceding AEC and post-filter (PF).

The code has been developed and tested in MATLAB R2024a.

# File structure

* [Main.m](Main.m): Main file to run the code.
* [LICENSE](LICENSE.md): License file.
* [ReadMe.md](ReadMe.md): ReadMe file.
* [Audio](Audio): Folder containing the audio files.
    - [sig.mat](Audio/sig.mat): File containing the desired speech, near-end room noise, echo, and loudspeaker signals. The speech and speech component in the echo are taken from the [VCTK corpus](https://datashare.ed.ac.uk/handle/10283/3443), which is made available under the Open Data Commons Attribution License (ODC-By) v1.0.
* [Util](Util): Auxiliary code.
    - [Filter](Util/Filter): Folder the containing auxiliary code for computing filters.
        + [applyFilterMultichannel.m](Util/Filter/applyFilterMultichannel.m): Performs multi-channel filtering.
        + [updateDifferenceCorrelation.m](Util/Filter/updateDifferenceCorrelation.m): Computes the difference between two correlation matrices using a generalised eigenvalue decomposition (GEVD).
        + [updateMWFGEVD.m](Util/Filter/updateMWFGEVD.m): Computes the GEVD of two correlation matrices. 
        + [updateMWFGEVDMultichannel.m](Util/Filter/updateMWFGEVDMultichannel.m): Computes the GEVD for multiple frequency channels by calling [updateMWFGEVD.m](Util/Filter/updateMWFGEVD.m) for each channel.
   - [Frequency_transformation](Util/Frequency_transformation): Folder containing the auxiliary code for the conversion between time- and frequency-domain.
        + [WOLA_analysis.m](Util/Frequency_transformation/WOLA_analysis.m): Weighted overlapp add (WOLA) analysis filterbank.
        + [WOLA_synthesis.m](Util/Frequency_transformation/WOLA_synthesis.m): WOLA synthesis filterbank.    
   - [Metrics](Util/Metrics): Folder containing the auxiliary code for the evaluation of the algorithms.
        + [calculateMetrics.m](Util/Metrics/calculateMetrics.m): Computes the signal-to-noise ratio (SNR), signal-to-echo ratio (SER), and speech distortion (SD).
        + [SD.m](Util/Metrics/SD.m): Computes the SD.
        + [SNR.m](Util/Metrics/SNR.m): Computes the SNR .
    - [Process](Util/Process):
        + [process.m](Util/Process/process.m): Performs combined AEC and NR.
        + [process_AEC.m](Util/Process/process_AEC.m): Performs AEC.
        + [process_MWFext.m](Util/Process/process_MWFext.m): Performs MWF<sub>ext</sub>.
        + [process_NR.m](Util/Process/process_NR.m): Performs NR.
        + [process_NRext.m](Util/Process/process_NRext.m) Performs NR<sub>ext</sub>.
        + [process_PF.m](Util/Process/process_PF.m): Performs PF.
    - [VAD](Util/VAD): Folder containing the auxiliary code for the voice activity detection (VAD).
        + [VAD.m](Util/VAD/VAD.m): Computes the VAD in the STFT domain.
     
# Audio examples
The following audio examples are obtained after running the [Main.m](Main.m) file. 

Desired speech signal:
https://github.com/user-attachments/assets/30cad189-2cc7-407c-8a25-729c46106a05

Microphone signal:
https://github.com/user-attachments/assets/bee464df-1bf4-4e65-9977-305435f8a761

MWF:
https://github.com/user-attachments/assets/0e477f49-5eca-4b35-b565-341149a85365

MWF<sub>ext</sub>:
https://github.com/user-attachments/assets/3341903d-ef31-4d45-ba59-17320e852633

AEC-NR:
https://github.com/user-attachments/assets/d01a3d63-8cf9-4aaa-9585-f4b1ad144d86

NR-AEC:
https://github.com/user-attachments/assets/79dcca12-b2ff-4d1c-ad3c-5366d7cc7af3

NR<sub>ext</sub>-AEC-PF:
https://github.com/user-attachments/assets/60f7a536-807e-4382-8607-91b3a02526dc

# Contact
Arnout Roebben, Toon van Waterschoot, Jan Wouters, and Marc Moonen\
Department of Electrical Engineering (ESAT)\
STADIUS Center for Dynamical Systems, Signal Processing and Data Analytics\
KU Leuven\
Leuven, Belgium\
E-mail: <arnout.roebben@esat.kuleuven.be>

# Acknowledgements
This research was carried out at the ESAT Laboratory of KU Leuven, in the frame of Research Council KU Leuven C14-21-0075 ”A holistic approach to the design of integrated and distributed digital signal processing algorithms for audio and speech communication devices”, and Aspirant Grant 11PDH24N (for A. Roebben) from the Research Foundation - Flanders (FWO).

# References
[1]
```
@misc{roebben2024integratedminimummeansquared,
      title={Integrated Minimum Mean Squared Error Algorithms for Combined Acoustic Echo Cancellation and Noise Reduction}, 
      author={Arnout Roebben and Toon van Waterschoot and Jan Wouters and Marc Moonen},
      year={2024},
      eprint={2412.04267},
      archivePrefix={arXiv},
      primaryClass={eess.AS},
      url={https://arxiv.org/abs/2412.04267}, 
}
```

[2]
```
@misc{roebbenGithubRepositoryIntegrated2024,
  title = {Github Repository: Integrated minimum mean squared error algorithms for combined acoustic echo cancellation and noise reduction},
  author = {Roebben, Arnout},
  year = {2024},
  journal = {GitHub},
  urldate = {2024},
  howpublished = {https://github.com/Arnout-Roebben/Integrated\_AEC\_NR,
  langid = {english}}
```
