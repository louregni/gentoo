# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )

MY_P="uTidylib-${PV}"
inherit distutils-r1

DESCRIPTION="TidyLib Python wrapper"
HOMEPAGE="https://cihar.com/software/utidylib/ https://pypi.org/project/uTidylib/"
SRC_URI="https://github.com/nijel/utidylib/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc ~ppc64 ~x86"

RDEPEND="app-text/tidy-html5"
DEPEND="dev-python/six[${PYTHON_USEDEP}]"

distutils_enable_tests pytest
distutils_enable_sphinx doc

EPYTEST_DESELECT=(
	# https://github.com/nijel/utidylib/issues/9
	tidy/test_tidy.py::TidyTestCase::test_missing_load
)
