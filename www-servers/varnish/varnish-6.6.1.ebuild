# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python3_{7..9} )

inherit autotools systemd python-r1

DESCRIPTION="Varnish is a state-of-the-art, high-performance HTTP accelerator"
HOMEPAGE="https://varnish-cache.org/"
SRC_URI="http://varnish-cache.org/_downloads/${P}.tgz"

LICENSE="BSD-2 GPL-2"
SLOT="0/2"
KEYWORDS="~amd64 ~mips ~ppc ~ppc64 ~x86"
IUSE="jemalloc jit static-libs"

CDEPEND="
	sys-libs/readline:0=
	dev-libs/libpcre[jit?]
	jemalloc? ( dev-libs/jemalloc )
	sys-libs/ncurses:0="

#varnish compiles stuff at run time
RDEPEND="
	${PYTHON_DEPS}
	${CDEPEND}
	acct-user/varnish
	acct-group/varnish
	sys-devel/gcc"

DEPEND="
	${CDEPEND}
	dev-python/docutils
	dev-python/sphinx
	virtual/pkgconfig"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="test" #315725

src_prepare() {
	# Remove -Werror bug #528354
	sed -i -e 's/-Werror\([^=]\)/\1/g' configure.ac

	# Upstream doesn't put varnish.m4 in the m4/ directory
	# We link because the Makefiles look for the file in
	# the original location
	ln -sf ../varnish.m4 m4/varnish.m4

	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable static-libs static)
		$(use_enable jit pcre-jit)
		$(use_with jemalloc)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" install

	python_replicate_script "${D}/usr/share/varnish/vmodtool.py"

	newinitd "${FILESDIR}"/varnishlog.initd varnishlog
	newconfd "${FILESDIR}"/varnishlog.confd varnishlog

	newinitd "${FILESDIR}"/varnishncsa.initd varnishncsa
	newconfd "${FILESDIR}"/varnishncsa.confd varnishncsa

	newinitd "${FILESDIR}"/varnishd.initd-r4 varnishd
	newconfd "${FILESDIR}"/varnishd.confd-r4 varnishd

	insinto /etc/logrotate.d/
	newins "${FILESDIR}/varnishd.logrotate-r2" varnishd

	diropts -m750

	keepdir /var/lib/varnish
	keepdir /var/log/varnish

	systemd_dounit "${FILESDIR}/${PN}d.service"

	insinto /etc/varnish/
	doins vmod/vmod_vtc.vcc
	doins vmod/vmod_directors.vcc
	doins vmod/vmod_blob.vcc
	doins vmod/vmod_proxy.vcc
	doins vmod/vmod_debug.vcc
	doins vmod/vmod_std.vcc
	doins vmod/vmod_unix.vcc
	doins vmod/vmod_cookie.vcc
	doins vmod/vmod_purge.vcc
	doins etc/example.vcl

	dodoc README.rst
	dodoc doc/changes.rst

	fowners root:varnish /etc/varnish/
	fowners varnish:varnish /var/lib/varnish/
	fperms 0750 /var/lib/varnish/ /etc/varnish/
}
