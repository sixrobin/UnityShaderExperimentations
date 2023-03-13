using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Bloom : MonoBehaviour
{
    [Range(0.0f, 0.99f)]
    public float _strength = 0.4f;

    Camera cam;

    private Shader bloomShader = null;
    private Material bloomMaterial = null;
    bool isSupported = true;

    void Awake()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        bloomShader = Shader.Find("MyShaders/Bloom");
        bloomMaterial = CheckShader(bloomShader, bloomMaterial);

        return isSupported;
    }

    protected Material CheckShader(Shader s, Material m)
    {
        if (s == null)
        {
            Debug.Log("Missing shader on " + ToString());
            this.enabled = false;
            return null;
        }

        if (s.isSupported == false)
        {
            Debug.Log("The shader " + s.ToString() + " is not supported on this platform");
            this.enabled = false;
            return null;
        }

        cam = GetComponent<Camera>();
        cam.renderingPath = RenderingPath.UsePlayerSettings;

        m = new Material(s);
        m.hideFlags = HideFlags.DontSave;

        if (s.isSupported && m && m.shader == s)
            return m;

        return m;
    }

    void OnDestroy()
    {
#if UNITY_EDITOR
        DestroyImmediate(bloomMaterial);
#else
        Destroy(bloomMaterial);
#endif
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (CheckResources() == false)
        {
            Graphics.Blit(source, destination);
            return;
        }

        bloomMaterial.SetFloat("_strength", _strength);

        Graphics.Blit(source, destination, bloomMaterial);
    }
}
