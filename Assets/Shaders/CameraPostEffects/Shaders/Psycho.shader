// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Psycho" {
	
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_strength("Amplitude", float) = 5
		_speed ("Time Controller", float) = 1
		_parasite ("Parasite", float) = 0.5
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _strength;
	float _speed;
	float _parasite;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float2 uv = i.uv;
		uv.x += sin(_Time.z * _speed + uv.x * _strength * _strength) * 0.01;
		uv.y += cos(_Time.z * _speed + uv.y * _strength * _strength) * 0.01;

		float x = i.uv.x * i.uv.y * _Time * 1000 + 10;
		x = fmod(x, 20) * fmod(x, 150);
		float dx = fmod(x, 0.01f);

		float4 sum = (float4)0;
		sum = -9 * tex2D(_MainTex, uv);

		float3 xxx = (float3)0;
		xxx = sum.rgb + sum.rgb * saturate(0.001 + dx.xxx * 100);

		float ratio = 0.0001;

		float2 offsets[9] = 
		{  
			float2(-1, -1),
			float2(-1, 0),
			float2(-1, 1),
			float2(0, -1),
			float2(0, 0),  
			float2(0, 1),  
			float2(1, -1),
			float2(1, 0),
			float2(1, 1)
		}; 

		for (int j = 0; j < 9; j++)
			sum += tex2D(_MainTex, i.uv + ratio * offsets[j]);
	
		sum /= ratio;

		return fixed4((sum + (_parasite * 200) * xxx), 1);
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
			ENDCG
		}  
	}
	Fallback off	
}
