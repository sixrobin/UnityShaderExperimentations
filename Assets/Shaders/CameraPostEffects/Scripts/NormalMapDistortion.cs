using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class NormalMapDistortion : MonoBehaviour
{
    [Range(-1.0f, 1.0f)]
    public float _speedX = 0.5f;
    [Range(-1.0f, 1.0f)]
    public float _speedY = -0.5f;
    [Range(0.0f, 5.0f)]
    public float _strength = 2.0f;

    public Texture _normalMap;

    Camera cam;

    private Shader normalMapDistortionShader = null;
	private Material normalMapDistortionMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        normalMapDistortionShader = Shader.Find("MyShaders/NormalMapDistortion");
        normalMapDistortionMaterial = CheckShader(normalMapDistortionShader, normalMapDistortionMaterial);

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
        DestroyImmediate(normalMapDistortionMaterial);
#else
        Destroy(normalMapDistortionMaterial);
#endif
    }

    void Awake()
    {
        if (_normalMap == null)
            _normalMap = Resources.Load("NormalMap512") as Texture;
    }

	void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

		normalMapDistortionMaterial.SetFloat ("_speedX", _speedX * 2);
		normalMapDistortionMaterial.SetFloat ("_speedY", _speedY * 2);
		normalMapDistortionMaterial.SetTexture ("_normalMap", _normalMap);
        normalMapDistortionMaterial.SetFloat("_strength", _strength);

        Graphics.Blit(source, destination, normalMapDistortionMaterial);
	}
}
