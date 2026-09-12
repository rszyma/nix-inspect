project( 'nix-inspect-worker'
       , ['c', 'cpp']
       , default_options : ['cpp_std=gnu++20']
       , version: 'nightly'
       )

config_h = configuration_data()

configure_file(
  output: 'nix-inspect-worker-config.h',
  configuration: config_h,
)

cpp = meson.get_compiler('cpp')

add_project_arguments([
  '-I' + meson.project_build_root(),
], language: 'cpp')

pkgconfig = import('pkgconfig')

nix_all = [ dependency('nix-expr')
          , dependency('nix-cmd')
          , dependency('nix-store')
          , dependency('nix-main')
          , dependency('nix-flake')
          ]

nix_inspect = executable(
  'nix-inspect-worker',
  ['main.cc', 'inspector.cc'],
  dependencies: [
                nix_all,
                ]
, install: true
)
