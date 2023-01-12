using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class CameraCRT : MonoBehaviour
{
    [SerializeField] private Shader _shader = null;

    private Material _material;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_shader == null)
            return;

        if (_material == null)
            _material = new Material(_shader);

        Graphics.Blit(source, destination, _material);
    }

    private void OnDisable()
    {
        DestroyImmediate(_material);
    }
}
