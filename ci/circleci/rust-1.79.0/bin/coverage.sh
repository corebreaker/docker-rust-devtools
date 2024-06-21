#! /usr/bin/env bash

OPT_ARGS=
if [ "$1" = "-p" ]; then
  OPT_ARGS=" --prefix-dir '$2'"
  shift 2
fi

while [ "$1" = "-i" ]; do
  OPT_ARGS="$OPT_ARGS --ignore '$2'"
  shift 2
done

NAME="$1"
if [ -z $NAME ]; then
  NAME=$(get_crate_name.py)
fi

echo "Name: $NAME"

export CARGO_INCREMENTAL=0
export RUSTFLAGS="-Cinstrument-coverage -Zprofile -Ccodegen-units=1 -Copt-level=0 -Coverflow-checks=off"
export LLVM_PROFILE_FILE="default.profraw"
export CARGO_NET_GIT_FETCH_WITH_CLI=true

echo 'Run tests'
cargo +nightly test --lib
if [ $? -ne 0 ]; then
  exit 1
fi

mkdir target/coverage >/dev/null 2>&1

echo 'Select files and store them into a Zip archive'
zip -0 ./target/coverage/cov-binaries.zip $(find target/debug/deps -name "$NAME*.gc*" -print)

COV_CMD='/tmp/do-coverage.sh'
cat >$COV_CMD <<EOF
grcov ./target/coverage/cov-binaries.zip \
  -s . \
  -b target \
  -t coveralls+ \
  --token $COVERALLS_REPO_TOKEN \
  --excl-line 'unreachable' \
  --excl-start '// no-coverage:start' \
  --excl-stop '// no-coverage:stop' \
  $OPT_ARGS \
  --ignore '*/.cargo/*' \
  --ignore '*/target/debug/build/*' \
  --llvm \
  --ignore-not-existing \
  -o target/coverage/coveralls.json
EOF

echo 'Produce file for Coveralls with this command:'
cat $COV_CMD
bash $COV_CMD

