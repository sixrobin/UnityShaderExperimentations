// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Toon" {

	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_size("Size", int) = 512
		_strength("Strength FX", float) = 0.5
		_poster("Posterization", int) = 4
		_global("Global Illumination", float) = 0.8
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float4 _MainTex_ST;
	int _size;
	float _strength;
	int _poster;
	float _global;

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	v2f vert(appdata_full v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}

	float4 frag(v2f i) :COLOR
	{
		float3 lum = float3(0.2125, 0.7154, 0.0721);

		float o00 = dot(tex2D(_MainTex, i.uv - float2(1, 1) / _size).rgb, lum);
		float o10 = dot(tex2D(_MainTex, i.uv - float2(0, 1) / _size).rgb, lum);
		float o20 = dot(tex2D(_MainTex, i.uv - float2(-1, 1) / _size).rgb, lum);
		float o01 = dot(tex2D(_MainTex, i.uv - float2(1, 0) / _size).rgb, lum);
		float o11 = dot(tex2D(_MainTex, i.uv).rgb, lum); //
		float o21 = dot(tex2D(_MainTex, i.uv - float2(-1, 0) / _size).rgb, lum);
		float o02 = dot(tex2D(_MainTex, i.uv - float2(1, -1) / _size).rgb, lum);
		float o12 = dot(tex2D(_MainTex, i.uv - float2(0, -1) / _size).rgb, lum);
		float o22 = dot(tex2D(_MainTex, i.uv - float2(-1, -1) / _size).rgb, lum);

		float GX = -1 * o00 + o20 + -2 * o01 + 2 * o21 - o02 + o22;
		float GY = o00 + 2 * o10 + o20 - o02 - 2 * o12 - o22;
		float G = abs(GX) + abs(GY);

		float4 c = 0;
		c = length(float2(GX, GY));

		float4 sum = tex2D(_MainTex, i.uv);
		sum *= _poster;
		sum = floor(sum);
		sum /= _poster;
		sum = pow(sum, _global);
#ifdef GRAYSCALE
		sum = dot(float3(0.33, 0.33, 0.33), sum.rgb);
#endif
		if (c.x < _strength)
			return sum;
		else
		{
			float4 c0, c1, c2, c3 = (float4)0;

			c0 = tex2D(_MainTex, i.uv + float2(0.5, 1) / _size);
			c1 = tex2D(_MainTex, i.uv + float2(-0.5, 1) / _size);
			c2 = tex2D(_MainTex, i.uv + float2(0.5, -1) / _size);
			c3 = tex2D(_MainTex, i.uv + float2(-0.5, -1) / _size);

			sum = (sum * (c0 + c1 + c2 + c3)) * 0.01;

			return fixed4(sum);
		}
	}

	ENDCG

	Subshader
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature GRAYSCALE
			ENDCG
		}
	}
	Fallback off
}
