import vscode, { ExtensionContext } from "vscode";

import { getExtensionContext } from "../globals/extensionContext";
import { getModel, getModels } from "../services/codeAssistant";
import { setDefaultStatus, setLoadingStatus } from "../statusBar/statusBar";
import { requiresToken } from "../utilities/guards";

let modelsList: ModelInfo[] = [];

export let currentModel: ModelInfo | undefined = undefined;

export function setAsCurrentModel(model: ModelInfo): void {
  currentModel = model;
  if (modelsList?.length > 0) {
    const index = modelsList.findIndex((m) => m._id == model._id)
    if (index > -1) modelsList[index] = model;
  }
}

export async function initModels(context: ExtensionContext | null): Promise<void> {
  if (!context) return;

  await requiresToken(context)

  if (!modelsList || modelsList.length == 0) {
    try {
      setLoadingStatus()
      modelsList = await getModels();
    } catch (err) {
      vscode.window.showErrorMessage((err as Error).message);
      currentModel = undefined;
      setDefaultStatus();
      return;
    }
  }

  if (modelsList?.length == 1) {
    const model = await getModel(modelsList[0]._id);
    setAsCurrentModel(model);
  }

  setDefaultStatus();
}

async function handler(): Promise<ModelInfo | undefined> {
  const context = getExtensionContext();
  await initModels(context);

  const modelNames = [...modelsList.map((m) => m.display_name)];
  const result = await vscode.window.showQuickPick(modelNames, { title: "Select Model" });
  if (result) {
    const selectedModel = modelsList.find((m) => m.display_name == result);
    if (selectedModel) {
      if (selectedModel.disclaimer?.accepted) {
        currentModel = selectedModel;
        setDefaultStatus();
      } else {
        currentModel = undefined;
        try {
          setLoadingStatus()
          currentModel = await getModel(selectedModel._id);
        } catch (err) {
          vscode.window.showErrorMessage((err as Error).message);
          return;
        } finally {
          setDefaultStatus();
        }

        return currentModel;
      }
    } else {
      vscode.window.showInformationMessage("No model selected");
      currentModel = undefined;
      setDefaultStatus();
    }
  }

  return;
}

const command: CommandModule = {
  identifier: "qiskit-vscode.select-model",
  handler,
};

export default command;
