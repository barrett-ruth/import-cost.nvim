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

const filetypes = new Map([
  ["j", Lang.JAVASCRIPT],
  ["s", Lang.SVELTE],
  ["t", Lang.TYPESCRIPT],
  ["v", Lang.VUE],
]);

const init = async () => {
  const [path, filetype] = process.argv.slice(2);
  const lang = filetypes.get(filetype[0]);
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
