Shader "MyShaders/BigNoise" {

	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_frequency("Frequency", float) = 2
		_contrast("Contrast", float) = 2
		_size("Parasite Size", float) = 2
		_dispersal("Dispersion Force", float) = 0.25
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	uniform sampler2D _MainTex;
	float _frequency;
	float _contrast;
	float _size;
	float _dispersal;

	struct v2f
	{
		float4 position : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	float rand(float3 co) 
	{
		return frac(sin(dot(co.xyz ,float3(13.1, 78.2, 45.5))) * 50000);
	}

	float4 frag(v2f i) : SV_Target
	{
		float dx = 1 - abs(distance(i.uv.x, _frequency));
		float dy = 1 - abs(distance(i.uv.y, _contrast));

		dy = ((int)(dy * 8)) / 8.0;
		i.uv.y += dy * 0.025 + rand(float3(dy, dy, dy)).r / 500;
		i.uv.x += dx * 0.025 + rand(float3(dx, dx, dx)).r / 500;

		i.uv.x = i.uv.x % 1;
		i.uv.y = i.uv.y % 1;

		fixed4 sum = tex2D(_MainTex, i.uv);

		float x = ((int)(i.uv.x * 320 / _size)) / 320.0 / _size;
		float y = ((int)(i.uv.y * 240 / _size)) / 240.0 / _size;

		sum -= rand(float3(x, y, _frequency)) * _contrast / 5;

		return fixed4(sum);
	}

	ENDCG

	SubShader
	{
		Pass
		{
			ZTest Always 
			Cull Off 
			ZWrite Off 
			Fog{ Mode off }

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest 
			ENDCG
		}
	}
}
