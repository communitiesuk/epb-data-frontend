# Energy Performance Certificate Data

Frontend for the Energy Performance Certificate Data

## Getting Started

Make sure you have the following installed:

* [Ruby](https://www.ruby-lang.org)
  * [Bundler](https://bundler.io) to install dependencies found in `Gemfile`
* [Git](https://git-scm.com) (_optional_)

### Install

This short guide will use `Git`.

1. Clone the repository: `$ git clone git@github.com:communitiesuk/epb-data-frontend.git`
2. Change into the cloned repository: `$ cd epb-data-frontend`
3. Install the Ruby gems: `$ bundle install`
4. Build the frontend assets: `$ make frontend-build`

## Test

### Prerequisites

To run the Capybara user-journey tests, the following must be downloaded and
installed.

* [Chrome](https://www.google.com/chrome)
* [ChromeDriver](https://chromedriver.chromium.org/downloads)
  * download the same ChromeDriver version as your version of Chrome.

Depending on how ChromeDriver was installed, it may need to be added to the
`PATH` environment variable. Instructions below are for MacOS users.

1. Create local `bin` directory: `$ mkdir ~/bin`
2. Move the downloaded ChromeDriver to the `bin` directory:
   `$ mv ~/Downloads/chromedriver ~/bin`
3. Make the ChromeDriver executable: `cd ~/bin && chmod +x chromedriver`
4. Add the `bin` directory to the `PATH` environment variable in your shell
   profile:

```bash
# ~/.bash_profile, ~/.zprofile, etc

...
export PATH="$PATH:$HOME/bin" # Add this line at the end of the file
```

Run `$ source ~/.bash_profile`, or `.zprofile`. Alternatively, restart the
terminal.

5. You must add additional local hosts to your hosts file on your machine with:

```
127.0.0.1	get-energy-performance-data.epb-frontend
127.0.0.1	get-energy-performance-data.local.gov.uk
```
You can add these to your hosts file automatically by running `$ sudo make hosts`.
You can check what hosts you already have by typing `$ cat /etc/hosts` in the
frontend directory.

Don't forget to ensure bundles are up to date

### Test suites

To run the respective test suites:

* All tests: `$ make test`

## Usage

### Running the frontend

#### The test stubs server

1. To run the test stubs server (i.e. the frontend in isolation from the local API),
   change directory into the root of the cloned folder: `$ cd epb-frontend`
2. Start the web server(s) using the following command: `$ make run ARGS=config_test.ru`
3. Open <http://get-energy-performance-data.epb-frontend:9292> in your favourite browser to
   run the test stubs server.

#### The integrated server

1. To run the local frontend alongside your local API in Docker, make sure that
   the Docker images from the epb-dev-tools repo are running
2. Then access the frontend at <http://get-energy-performance-data.epb-frontend> (without the specified ports).

