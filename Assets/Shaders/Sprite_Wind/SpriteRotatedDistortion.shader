Shader "Sprites/Distortion/Rotated"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Rotation ("Rotation", float) = 0
        _RotationSpeed ("Rotation Speed", float) = 1
    	_RotationMidX("Rotation Mid X", float) = 0.5
    	_RotationMidY("Rotation Mid Y", float) = 0.5

	    [Space(5)]
    	
    	[Header(PLASMA DISTORTION)]
    	[Space(5)]
	    _DistortionMask ("Distortion Mask", 2D) = "white" {}
    	[PerRendererData] _DistortionTimeOffset ("Distortion Time Offset", float) = 0
    	
	    [Space(5)]

	    [Header(SPRITE DEFAULT DATA)]
	    [Space(5)]
        _Color ("Tint", Color) = (1, 1, 1, 1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
        [HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM

            #include "UnitySprites.cginc"

            #pragma vertex SpriteVert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile_local _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #pragma shader_feature _SHOWDISTORTION_ON

            fixed _Rotation;
            fixed _RotationSpeed;
            fixed _RotationMidX;
            fixed _RotationMidY;
            
            sampler2D _DistortionMask;
            float4 _DistortionMask_ST;

			float2 rotate_uv(float2 uv, const float rotation, float2 mid)
			{
			    return float2(cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x,
							  cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y);
			}
            
			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = i.texcoord;
			    float2 uv_rotated = rotate_uv(uv, sin(_Time.y * _RotationSpeed + sin(_Time.y) * 19 + cos(_Time.y) * 7) * _Rotation * _RotationSpeed, float2(_RotationMidX, _RotationMidY));
				// return length(uv - float2(_RotationMidX, _RotationMidY)); // Rotation center visualizer.
				// return fixed4(uv, 0, 1);
				
				fixed4 distortion_mask = tex2D(_DistortionMask, uv);
				fixed4 sprite = SampleSpriteTexture(lerp(uv, uv_rotated, distortion_mask));
				
				fixed4 color = sprite * i.color;
				color *= _Color.a;
				color.rgb *= color.a;

				return color;
			}
            
            ENDCG
        }
    }
}