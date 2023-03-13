using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class GrayscaleRGB : MonoBehaviour
{
    public enum myColor { Red, Green, Blue };
    public myColor color;
    int _color = 0;

    [Range(0.0f, 2.0f)]
    public float _smoothness = 0.0f;

    Camera cam;

    private Shader grayscaleRGBShader = null;
    private Material grayscaleRGBMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        grayscaleRGBShader = Shader.Find("MyShaders/GrayscaleRGB");
        grayscaleRGBMaterial = CheckShader(grayscaleRGBShader, grayscaleRGBMaterial);

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
        DestroyImmediate(grayscaleRGBMaterial);
#else
        Destroy(grayscaleRGBMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
        if (CheckResources() == false)
	    {
			Graphics.Blit (source, destination);
			return;
		}

        if (color == myColor.Red)
            _color = 0;
        if (color == myColor.Green)
            _color = 1;
        if (color == myColor.Blue)
            _color = 2;

        grayscaleRGBMaterial.SetInt("_color", _color);
        grayscaleRGBMaterial.SetFloat("_smoothness", _smoothness);
           
        Graphics.Blit (source, destination, grayscaleRGBMaterial);
	}
}
