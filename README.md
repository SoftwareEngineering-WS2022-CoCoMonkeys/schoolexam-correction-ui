<div id="top"></div>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![AGPL License][license-shield]][license-url]


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui">
    <img src="images/selogo2.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">SchoolExam Correction UI</h3>

  <p align="center">
    project_description
    <br />
    <a href="https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/
schoolexam-correction-ui/issues">Report Bug</a>
    ·
    <a href="https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

SchoolExam has originated from a design thinking process developed as part of a course about software engineering with the goal of improving the exam process and exam management at schools. This repository is the component allowing teachers to correct the digitalized submissions.

### Built With

- [Flutter](https://flutter.dev/)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [perfect_freehand](https://github.com/steveruizok/perfect-freehand)
- [syncfusion_flutter_pdf](https://pub.dev/packages/syncfusion_flutter_pdf)
- [native_pdf_view](https://pub.dev/packages/native_pdf_view)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

As the correction UI is just one component of an overall system, dependencies require their existence.

<p align="right">(<a href="#top">back to top</a>)</p>

### Prerequisites

For the UI to properly function, a running instance of the SchoolExam backend is required. Further information can be found <a href="https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam">here</a>.

After setting up the backend, u require Flutter (and an appropriate development environment). Using flutter the dependencies of the project are retrieved using.

```
flutter pub get
```

Before starting your application, configure the **api.cfg** found in the assets to point to your SchoolExam backend.

<p align="right">(<a href="#top">back to top</a>)</p>

## Usage

After setting up a working environment, the UI can be used to (mainly) correct uploaded submissions.

<p align="right">(<a href="#top">back to top</a>)</p>

## Roadmap

- implement various analytics for individual students to analyze and optimize teaching at schools
- support randomization of tasks
- support exams (writing tasks) that have a grading scheme different from points
- add additional pages dynamically during exams based on demand
- API for review such that points can be corrected based on complaints from students
- store correction overlay independent from scanned PDF
- image recognition for automized correction (multiple choice, matching)

See the [open issues](https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam/issues) for a full list of
proposed features (and known issues).

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Torben Soennecken - soennecken@rootitup.de

Project
Link: [https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui](https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- []()#wirfuerschule for the insights on the current situation in schools
- []()Capgemini for the valuable workshops with feedback for the architecture
- []()ISSE chair at the University of Augsburg for giving us room to implement our idea
- []()adesso for providing us a productive collaborative workspace

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam.svg?style=for-the-badge
[contributors-url]: https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui.svg?style=for-the-badge
[forks-url]: https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui/network/members
[stars-shield]: https://img.shields.io/github/stars/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui.svg?style=for-the-badge
[stars-url]: https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui/stargazers
[issues-shield]: https://img.shields.io/github/issues/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui.svg?style=for-the-badge
[issues-url]: https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui/issues
[license-shield]: https://img.shields.io/github/license/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui.svg?style=for-the-badge
[license-url]: https://github.com/SoftwareEngineering-WS2022-CoCoMonkeys/schoolexam-correction-ui/blob/main/gnu-agpl-v3.0.md
