using UnityEditor;
using UnityEngine;
using System.IO;

namespace FmdlStudio.Editor
{
    public class GltfMaterialRenamer : AssetPostprocessor
    {
        private static readonly string[] GltfExtensions = { ".glb", ".gltf" };

        private static void OnPostprocessAllAssets(
            string[] importedAssets,
            string[] deletedAssets,
            string[] movedAssets,
            string[] movedFromAssetPaths)
        {
            foreach (string assetPath in importedAssets)
            {
                string extension = Path.GetExtension(assetPath).ToLowerInvariant();

                if (System.Array.IndexOf(GltfExtensions, extension) < 0)
                    continue;

                ExtractAndRenameMaterials(assetPath);
            }
        }

        private static void ExtractAndRenameMaterials(string assetPath)
        {
            string modelName = Path.GetFileNameWithoutExtension(assetPath);
            string assetDirectory = Path.GetDirectoryName(assetPath);
            string materialsFolder = Path.Combine(assetDirectory, "Materials");

            // Create Materials folder if it doesn't exist
            if (!AssetDatabase.IsValidFolder(materialsFolder))
            {
                AssetDatabase.CreateFolder(assetDirectory, "Materials");
            }

            Object[] subAssets = AssetDatabase.LoadAllAssetsAtPath(assetPath);

            foreach (Object subAsset in subAssets)
            {
                if (subAsset is Material material)
                {
                    string originalName = material.name;
                    string newName = modelName + "-" + originalName;
                    string materialPath = Path.Combine(materialsFolder, newName + ".mat");

                    // Skip if material already extracted
                    if (File.Exists(materialPath))
                    {
                        Debug.Log($"Material already exists: {materialPath}");
                        continue;
                    }

                    // Create a copy of the material
                    Material extractedMaterial = new Material(material);
                    extractedMaterial.name = newName;

                    // Save as standalone asset
                    AssetDatabase.CreateAsset(extractedMaterial, materialPath);
                    Debug.Log($"Extracted material: {originalName} -> {materialPath}");
                }
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            // Remap materials in the importer
            RemapMaterials(assetPath, modelName, materialsFolder);
        }

        private static void RemapMaterials(string assetPath, string modelName, string materialsFolder)
        {
            var importer = AssetImporter.GetAtPath(assetPath);
            if (importer == null) return;

            // Load all materials from the Materials folder that match this model
            string[] materialGuids = AssetDatabase.FindAssets("t:Material", new[] { materialsFolder });

            var remap = new System.Collections.Generic.Dictionary<string, Material>();

            foreach (string guid in materialGuids)
            {
                string matPath = AssetDatabase.GUIDToAssetPath(guid);
                string matName = Path.GetFileNameWithoutExtension(matPath);

                // Check if this material belongs to this model
                if (matName.StartsWith(modelName + "-"))
                {
                    string originalName = matName.Substring(modelName.Length + 1);
                    Material mat = AssetDatabase.LoadAssetAtPath<Material>(matPath);
                    if (mat != null)
                    {
                        remap[originalName] = mat;
                    }
                }
            }

            // Apply remapping using reflection or reimport
            // For glTFast, we need to update the prefab instances
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
            if (prefab != null)
            {
                var renderers = prefab.GetComponentsInChildren<Renderer>(true);
                foreach (var renderer in renderers)
                {
                    var materials = renderer.sharedMaterials;
                    bool changed = false;

                    for (int i = 0; i < materials.Length; i++)
                    {
                        if (materials[i] != null && remap.TryGetValue(materials[i].name, out Material newMat))
                        {
                            materials[i] = newMat;
                            changed = true;
                        }
                    }

                    if (changed)
                    {
                        renderer.sharedMaterials = materials;
                    }
                }

                EditorUtility.SetDirty(prefab);
                AssetDatabase.SaveAssets();
            }
        }
    }
}
