using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Acid : MonoBehaviour
{
    [Range(0.0f, 10.0f)]
    public float _strength = 5.0f;
    [Range(0.0f, 2.0f)]
    public float _colorAmplitude = 1.0f;
    [Range(0.0f, 5.0f)]
    public float _colorSpeed = 2.0f;
    [Range(0.0f, 5.0f)]
    public float _speed = 1.0f;

    Camera cam;

    private Shader acidShader = null;
    private Material acidMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        acidShader = Shader.Find("MyShaders/Acid");
        acidMaterial = CheckShader(acidShader, acidMaterial);

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
        DestroyImmediate(acidMaterial);
#else
        Destroy(acidMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

		acidMaterial.SetFloat ("_strength", _strength);
        acidMaterial.SetFloat("_colorSpeed", _colorSpeed);
        acidMaterial.SetFloat("_colorAmplitude", _colorAmplitude);
        acidMaterial.SetFloat("_speed", _speed);
        
        Graphics.Blit (source, destination, acidMaterial);
	}
}
