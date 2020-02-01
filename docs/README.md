# Envisaged-Redux Documentation

Documentation is written in Asciidoc with Asciidoctor extensions.

## Viewing in Gitlab

Gitlab *somewhat* supports rendering Asciidoc with Asciidoctor extensions. Certain features are still not implemented. 
To view the docs, go [here](index.adoc)

For viewing the docs with the full feature set, see Building Documentation below.

## Building Documentation

To build the documentation, you will need to install Asciidoctor. See [these instructions](https://asciidoctor.org/docs/install-toolchain/#installing-the-asciidoctor-rubygem) for installing it on various platforms.

If you wish to generate the documentation as a PDF, you will also need to install the `asciidoctor-pdf` extension after `asciidoctor` is installed. Instructions for this can be found [here](https://asciidoctor.org/docs/asciidoctor-pdf/#install-the-published-gem).

### HTML5

To generate the documentation in HTML5, run the following command in the `/docs` directory:

```bash
asciidoctor index.adoc
```

The output should be an `index.html` in the `/docs` directory.

### PDF

To generate the documentation in PDF, run the following command in the `/docs` directory.
Make sure that you have already installed the `asciidoctor-pdf` extension described above.

```bash
asciidoctor --backend pdf -r asciidoctor-pdf index.adoc
```

The output should be an `index.pdf` in the `/docs` directory.
