Shader "MyShaders/Bloom" {

	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_strength("Bloom Strength", float) = 0.4
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float _strength;

	float4 frag(v2f_img i) : COLOR
	{
		float4 sum = (float4)0;
		sum = tex2D(_MainTex, i.uv);

		sum.rgb += pow(sum.rgb, 1 - _strength);
		sum.rgb *= sum;
		sum.rgb += sum;

		float2 epicenter = float2(0.5, 0.5);
		int _samples = 7;

		for (int n = 0; n < _samples; n++)
		{
			float scale = 1.0f - _strength * 0.077 * (n / (float)(_samples));
			sum += tex2D(_MainTex, (i.uv - epicenter) * scale + epicenter);
		}

		sum /= _samples;

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
			Lighting Off 
			Fog{ Mode off }

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			ENDCG
		}
	}
	Fallback off
}
