const { cleanup, importCost, Lang } = require("import-cost");

process.stdin.setEncoding("utf8");

const receive = async () => {
  let result = "";

  for await (const chunk of process.stdin) result += chunk;

  return result;
};

// Pad data with '|' for combined chunks to be parsable
const give = (data) =>
  process.nextTick(() => process.stdout.write(`${JSON.stringify(data)}|`));

const init = async () => {
  const [path, filetype] = process.argv.slice(2);
  const lang =
    filetype.substring(0, "typescript".length) === "typescript"
      ? Lang.TYPESCRIPT
      : Lang.JAVASCRIPT;
  const contents = await receive();

  const emitter = importCost(path, contents, lang);

  emitter.on("error", (error) => {
    give({ type: "error", error });

    cleanup();
  });

  emitter.on("calculated", ({ line, string, size, gzip }) => {
    give({
      type: "calculated",
      data: { line, string, size, gzip },
    });
  });

  // Send done to ensure job stdin stays open
  emitter.on("done", (_) => {
    give({
      type: "done",
    });

    cleanup();
  });
};

try {
  init();
} catch {}
