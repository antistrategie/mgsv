using UnityEditor;

public class ModelImportDefaults : AssetPostprocessor
{
    void OnPreprocessModel()
    {
        ModelImporter importer = (ModelImporter)assetImporter;

        // Set material settings
        importer.materialLocation = ModelImporterMaterialLocation.External;
        importer.materialName = ModelImporterMaterialName.BasedOnModelNameAndMaterialName;
    }
}