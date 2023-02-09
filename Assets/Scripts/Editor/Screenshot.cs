namespace RSLib.Editor
{
	using UnityEditor;
	using UnityEngine;

	[ExecuteInEditMode]
	public class Screenshot : EditorWindow
	{
		private int _resolutionWidth = Screen.width;
		private int _resolutionHeight = Screen.height;
		private int _scale = 1;
		public Camera _targetCamera;

        private string _destinationFolder = string.Empty;
		public string _lastScreenshot = string.Empty;
        private RenderTexture _renderTexture;
		private bool _isTransparent;
        private bool _takeScreenshot;

		[MenuItem("RSLib/Screenshot")]
		public static void ShowWindow()
		{
			EditorWindow editorWindow = GetWindow(typeof(Screenshot));
			editorWindow.autoRepaintOnSceneChange = true;
			editorWindow.Show();
		}

		private string SetScreenshotName(int width, int height)
		{
			string screenshotName = string.Format("{0}/screen_{1}x{2}_{3}.png", _destinationFolder, width, height, System.DateTime.Now.ToString("yyyy-MM-dd_HH-mm"));
			_lastScreenshot = screenshotName;
			return screenshotName;
		}

		private void TakeScreenshot()
		{
			Debug.Log("Taking Screenshot");
			_takeScreenshot = true;
		}

		private void OnGUI()
		{
			EditorGUILayout.LabelField("Resolution", EditorStyles.boldLabel);
			_resolutionWidth = EditorGUILayout.IntField("Width", _resolutionWidth);
			_resolutionHeight = EditorGUILayout.IntField("Height", _resolutionHeight);

			EditorGUILayout.Space();
			EditorGUILayout.BeginVertical();

			EditorGUILayout.LabelField("Default Options", EditorStyles.boldLabel);

			if (GUILayout.Button("Set to game screen size"))
			{
				_resolutionHeight = (int)Handles.GetMainGameViewSize().y;
				_resolutionWidth = (int)Handles.GetMainGameViewSize().x;
			}

			if (GUILayout.Button("Set to default size"))
			{
				_resolutionHeight = 1080;
				_resolutionWidth = 1920;
				_scale = 1;
			}

			EditorGUILayout.EndVertical();

			_scale = EditorGUILayout.IntSlider("Screenshot scale", _scale, 1, 20);

			EditorGUILayout.Space();

			GUILayout.Label("Select the rendering camera (scene's main camera by default)", EditorStyles.boldLabel);
			_targetCamera = EditorGUILayout.ObjectField(_targetCamera, typeof(Camera), true, null) as Camera;
			if (_targetCamera == null)
                _targetCamera = Camera.main;

			_isTransparent = EditorGUILayout.Toggle("Transparent Background", _isTransparent);

			EditorGUILayout.Space();

			GUILayout.Label("Destination folder", EditorStyles.boldLabel);

			EditorGUILayout.BeginHorizontal();

			EditorGUILayout.TextField(_destinationFolder, GUILayout.ExpandWidth(false));
			if (GUILayout.Button("Browse", GUILayout.ExpandWidth(false)))
				_destinationFolder = EditorUtility.SaveFolderPanel("Choose destination folder", _destinationFolder, Application.dataPath);

			EditorGUILayout.EndHorizontal();
			EditorGUILayout.Space();

			EditorGUILayout.LabelField($"Screenshot resolution : {_resolutionWidth* _scale} x {_resolutionHeight * _scale} px", EditorStyles.boldLabel);

			if (GUILayout.Button("Take Screenshot", GUILayout.MinHeight(60f)))
			{
				if (string.IsNullOrEmpty(_destinationFolder))
					_destinationFolder = EditorUtility.SaveFolderPanel("Path to Save Images", _destinationFolder, Application.dataPath);

                TakeScreenshot();
			}

			EditorGUILayout.Space();
			EditorGUILayout.BeginHorizontal();

			if (GUILayout.Button("Open last screenshot", GUILayout.MaxWidth(160f), GUILayout.MinHeight(40f)))
				if (!string.IsNullOrEmpty(_lastScreenshot))
					Application.OpenURL($"file://{_lastScreenshot}");

			if (GUILayout.Button("Open folder", GUILayout.MaxWidth(100f), GUILayout.MinHeight(40f)))
				Application.OpenURL($"file://{_destinationFolder}");

			EditorGUILayout.EndHorizontal();

			if (_takeScreenshot)
			{
				int resolutionWidth = _resolutionWidth * _scale;
				int resolutionHeight = _resolutionHeight * _scale;
				RenderTexture renderTexture = new RenderTexture(resolutionWidth, resolutionHeight, 24);
				_targetCamera.targetTexture = renderTexture;

				TextureFormat textureFormat = _isTransparent ? TextureFormat.ARGB32 : TextureFormat.RGB24;

				Texture2D screenshot = new Texture2D(resolutionWidth, resolutionHeight, textureFormat, false);
				_targetCamera.Render();
				RenderTexture.active = renderTexture;
				screenshot.ReadPixels(new Rect(0f, 0f, resolutionWidth, resolutionHeight), 0, 0);
				_targetCamera.targetTexture = null;
				RenderTexture.active = null;
				byte[] bytes = screenshot.EncodeToPNG();
				string filename = SetScreenshotName(resolutionWidth, resolutionHeight);

				System.IO.File.WriteAllBytes(filename, bytes);
				Debug.Log($"Took screenshot to: {filename}");
				Application.OpenURL(filename);
				_takeScreenshot = false;
			}
		}
	}
}