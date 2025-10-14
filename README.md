This repo wraps and releases the FHIR validator CLI in Docker - as found on https://github.com/hapifhir/org.hl7.fhir.core/releases . New releases are automatically wrapped and published as Docker images.

Documentation for the CLI can be found on https://confluence.hl7.org/spaces/FHIR/pages/35718580/Using+the+FHIR+Validator#UsingtheFHIRValidator-PackageRegeneration (in regards to repackaging).

Example use of the Github Actions also located in this repo is as follows:

```
 ci-build-repackage:
    name: Build repackaged IG tarball
    runs-on: ubuntu-latest-4-cores
    container: ghcr.io/trifork/fhir-validator:latest
    needs: ci-build  
    env:
      NEW_VERSION: ${{ needs.ci-build.outputs.new_version }}

    steps:
      - uses: actions/download-artifact@v4
        with:
          name: output-directory
          path: "./output"

      - name: Add package to FHIR cache
        shell: bash
        run: |
          echo "New version: ${NEW_VERSION}"
          DAEMON_CACHE_DIR="/root/.fhir/packages/x.y.z#${NEW_VERSION}"
          rm -rf "${DAEMON_CACHE_DIR}"
          mkdir -p "${DAEMON_CACHE_DIR}"
          tar -xzf output/package.tgz -C "${DAEMON_CACHE_DIR}"

      - name: Repackage Implementation Guide
        uses: trifork/fhir-validator/.github/actions/repackage@main
        with:
          fhir_ig_id: x.y.z#${{ env.NEW_VERSION }}
          output: ./output/package-repackaged.tgz
          package_name: x.y.z.repackaged#${{ env.NEW_VERSION }}
          expansion_parameters: ${{ env.FHIR_CACHE_DIR }}/package/Parameters-expParam.json
```
