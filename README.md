# alpine-wheels
Provides missing alpine wheels (specially aarch64 which is what Docker on Mac (M1, M2, M3 chips) use) for pypi packages


## Using this index
### 1. If you're using requirements.txt
Add the following to your `requirements.txt` file:
```
--extra-index-url https://imranq2.github.io/alpine-wheels/docs/
```
### 2. If you're using `pip install`
Run the following command:
```
pip install --extra-index-url https://imranq2.github.io/alpine-wheels/docs/ <package-name>
```
### 3. If you're using `pipenv`
Add the following to your `Pipfile`:
```
[[source]]
name = "alpine-wheels-imranq2"
# https://github.com/imranq2/alpine-wheels/
url = "https://imranq2.github.io/alpine-wheels/docs/"
verify_ssl = true
```
and then for the packages you want to pull from this index:
```
shapely = {version = "==2.0.6", index = "alpine-wheels-imranq2"}
```
### 4. If you're using `poetry`
Add the following to your `pyproject.toml`:
```
[[tool.poetry.source]]
name = "alpine-wheels"
url = "https://imranq2.github.io/alpine-wheels/docs/"
```
and then for the packages you want to pull from this index:
```
shapely = {version = "==2.0.6", index = "alpine-wheels"}
```

## Creating a new wheel for an existing package
Run the Github Action workflow for the package you want to create a wheel for. The wheel will be uploaded as an artifact into this index.

You can choose the package from the dropdown in the Actions tab of the repository and then type in the version

## Creating a new wheel for a new package using the default Dockerfile
Create a new Github Action workflow in the repository of the package you want to create a wheel for. The wheel will be uploaded as an artifact into this index.

You can type in the name of the package in the custom_package_name field.  This will override the value from the dropdown.

The default Dockerfile installs the common build tools.  If you need additional build tools then create a custom Dockerfile per section below.

## Creating a new wheel for a new package using a custom Dockerfile
Create a new Github Action workflow in the repository of the package you want to create a wheel for. The wheel will be uploaded as an artifact into this index.

Create a new folder in the `packages` directory with the name of the package.  Add a Dockerfile to this folder with the build instructions for the package.

Add the new package to the dropdown list in `.github/workflows/build.yml` by adding the package name to the `packages` list.

Now you can follow the Creating a new wheel for an existing package section above.
