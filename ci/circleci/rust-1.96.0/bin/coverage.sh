#! /usr/bin/env bash
GRCOV_ARGS=
if [ "$1" = "-p" ]; then
  GRCOV_ARGS=" --prefix-dir '$2'"
  shift 2
fi

BUILD_ARGS=
if [ "$1" = "-f" ]; then
  BUILD_ARGS="-F $2"
  shift 2
elif [ "$1" = "-a" ]; then
  BUILD_ARGS="--all-features"
  shift
fi

if [ "$1" = "-w" ]; then
  BUILD_ARGS="$BUILD_ARGS --all-targets"
  shift
fi

while [ "$1" = "-i" ]; do
  GRCOV_ARGS="$GRCOV_ARGS --ignore '$2'"
  shift 2
done

export RUSTFLAGS='-Cinstrument-coverage'
export LLVM_PROFILE_FILE="`pwd`/target/profile/%p-%m.profraw"
export CARGO_INCREMENTAL=0
export CARGO_NET_GIT_FETCH_WITH_CLI=true

echo "Profile files: $LLVM_PROFILE_FILE"

echo 'Run tests'
cargo test --lib $BUILD_ARGS
if [ $? -ne 0 ]; then
  exit 1
fi

mkdir target/coverage >/dev/null 2>&1

COV_CMD='/tmp/do-coverage.sh'
cat >$COV_CMD <<EOF
grcov ./target/profile \
  -s . \
  -b ./target/debug \
  -t coveralls+ \
  --token $COVERALLS_REPO_TOKEN \
  --excl-line 'unreachable' \
  --excl-start '// no-coverage:start' \
  --excl-stop '// no-coverage:stop' \
  --keep-only '*/src/*' \
  $GRCOV_ARGS \
  --ignore '*/.cargo/*' \
  --ignore '*/target/debug/build/*' \
  --llvm \
  --ignore-not-existing \
  -o target/coverage/coveralls.json
EOF

echo 'Produce file for Coveralls with this command:'
cat $COV_CMD
bash $COV_CMD

