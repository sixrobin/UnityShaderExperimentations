using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Drunk : MonoBehaviour
{
    [Range(0.0f, 10.0f)]
	public float _strength = 2.0f;
    [Range(0.0f, 1.0f)]
    public float _amplitude = 0.5f;
    [Range(0.0f, 2.0f)]
    public float _speed = 1.0f;
       
    public bool _invert = false;

    Camera cam;

    private Shader drunkShader = null;
    private Material drunkMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        drunkShader = Shader.Find("MyShaders/Drunk");
        drunkMaterial = CheckShader(drunkShader, drunkMaterial);

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
        DestroyImmediate(drunkMaterial);
#else
        Destroy(drunkMaterial);
#endif
    }

	void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        if (_invert == true)
            drunkMaterial.EnableKeyword("INVERT");
        else
            drunkMaterial.DisableKeyword("INVERT");

        drunkMaterial.SetFloat ("_strength", _strength * 10);
        drunkMaterial.SetFloat("_amplitude", _amplitude);
        drunkMaterial.SetFloat("_speed", _speed);

        Graphics.Blit (source, destination, drunkMaterial);
	}
}
