// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Carnival" {
	
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "" {}
		_rgbTex("Ramp Texture (RGB)", 2D) = "" {}
		_channel("Correction Channel", int) = 5
		_intensityR("IntensityR", float) = 0.5
		_intensityG("IntensityG", float) = 0.5
		_intensityB("IntensityB", float) = 0.5
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct v2f 
	{
		float4 pos : POSITION;
		half2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	sampler2D _rgbTex;
	int _channel;
	float _intensityR;
	float _intensityG;
	float _intensityB;

	v2f vert(appdata_img v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	}

	fixed4 frag(v2f i) : COLOR
	{
		float4 sum = (fixed4)0;
		sum = _channel * tex2D(_MainTex, i.uv);

		float3 r, g, b = (fixed3)0;
		r = tex2D(_rgbTex, half2(sum.r, 0.5 / 4.0)).rgb * float3(_intensityR, 0, 0);
		g = tex2D(_rgbTex, half2(sum.g, 1.5 / 4.0)).rgb * float3(0, _intensityG, 0);
		b = tex2D(_rgbTex, half2(sum.b, 2.5 / 4.0)).rgb * float3(0, 0, _intensityB);

		sum = float4(r + g + b, sum.a);
		
		return fixed4(sum);
	}

	ENDCG

	Subshader 
	{
		Pass
		{
			ZTest Always 
			Cull Off 
			ZWrite Off
			Fog{ Mode off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			ENDCG
		}
	}
	Fallback off
}
