Shader "Sprites/Distortion"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}

	    [Space(5)]
    	
    	[Header(PLASMA DISTORTION)]
    	[Space(5)]
	    [Toggle] _ShowDistortion ("Show Distortion", float) = 0
	    _Scale ("Scale", float) = 1
        _ScaleHorizontal ("Scale Horizontal", float) = 1
        _ScaleVertical ("Scale Vertical", float) = 1
        _Speed ("Speed", float) = 1
        _RingsMultiplier ("Rings Multiplier", Range(0, 10)) = 1
        _DistortionIntensity ("Distortion Intensity", Range(0, 0.1)) = 0.1
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
            
            half _Scale;
            half _ScaleHorizontal;
            half _ScaleVertical;
            half _Speed;
            half _RingsMultiplier;
            half _DistortionIntensity;
            half _DistortionTimeOffset;

            float3 Plasma(float2 uv)
            {
                const float time = _Time.y * _Speed + _DistortionTimeOffset;

                uv = uv * _Scale - _Scale * 0.5;
                
                float wave1 = sin(uv.x + time) * _ScaleVertical;
                float wave2 = sin(uv.y + time) * _ScaleHorizontal;
                float wave3 = sin(uv.x + uv.y + time);

                float rings = sin(sqrt(uv.x * uv.x + uv.y * uv.y) + time);
                
                float final_value = wave1 + wave2 + wave3 + rings;

                const float rings_multiplier = final_value * UNITY_PI * _RingsMultiplier;
                float3 final_wave = float3(sin(rings_multiplier), cos(rings_multiplier), 0);
                final_wave = final_wave * 0.5 + 0.5;

                return final_wave;
            }
            
			fixed4 frag(v2f i) : SV_Target
			{
			    float2 uv = i.texcoord;
				
				float3 plasma = Plasma(uv);

				#if _SHOWDISTORTION_ON
				return float4(plasma, 1);
				#endif
				
				fixed4 sprite = SampleSpriteTexture(uv + plasma.r * _DistortionIntensity);

				fixed4 color = sprite * i.color;
				color *= _Color.a;
				color.rgb *= color.a;
				
				return color;
			}
            
            ENDCG
        }
    }
}