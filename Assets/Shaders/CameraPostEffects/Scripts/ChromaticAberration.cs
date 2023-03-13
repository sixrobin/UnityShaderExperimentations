using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]

public class ChromaticAberration : MonoBehaviour
{
    [Range(0.0f, 1.0f)]
    public float _chromaticAberration = 0.5f;
    public Vector2 _center = new Vector2(0.5f, 0.5f);

    Camera cam;

    private Shader chromaticAberrationShader;
    private Material chromaticAberrationMaterial;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        chromaticAberrationShader = Shader.Find("MyShaders/ChromaticAberration");
        chromaticAberrationMaterial = CheckShader(chromaticAberrationShader, chromaticAberrationMaterial);

        return isSupported;
    }

    protected Material CheckShader(Shader s, Material m)
    {
        if (s == null)
        {
            Debug.Log("Missing shader in " + ToString());
            enabled = false;
            return null;
        }

        if (s.isSupported == false)
        {
            Debug.Log("The shader " + s.ToString() + " is not supported on this platform");
            enabled = false;
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
        DestroyImmediate(chromaticAberrationMaterial);
#else
        Destroy(chromaticAberrationMaterial);
#endif
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (CheckResources() == false)
        {
            Graphics.Blit(source, destination);
            return;
        }

        chromaticAberrationMaterial.SetFloat("_chromaticAberration", 0.02f * _chromaticAberration);
        chromaticAberrationMaterial.SetFloat("_centerX", _center.x);
        chromaticAberrationMaterial.SetFloat("_centerY", _center.y);

        Graphics.Blit(source, destination, chromaticAberrationMaterial);
    }
}