Shader "MyShader/c7/ds_normalMapShader"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white"{}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)

		_BumpMap("BumpMap", 2D) = "bump"{}
		_BumpScale("BumpScale", Float) = 1.0
		_SpecularMask("SpecularMask", 2D) = "white"{}
		_SpecularScale("SpecularScale", Float) = 1.0
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess("Shininess", Range(8, 256)) = 128
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;

			sampler2D _BumpMap;
			float _BumpScale;
			sampler2D _SpecularMask;
			float _SpecularScale;
			fixed4 _Specular;
			float _Shininess;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 t2w_0 : TEXCOORD0;
				float4 t2w_1 : TEXCOORD1;
				float4 t2w_2 : TEXCOORD2;
				float2 uv : TEXCOORD3;
			};

			v2f Vert(in a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				fixed3 worldNormal = UnityObjectToWorldNormal( i.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( i.tangent.xyz );
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * i.tangent.w;

				o.t2w_0.xyz = float3(worldTangent.x, worldBinormal.x, worldNormal.x);
				o.t2w_1.xyz = float3(worldTangent.y, worldBinormal.y, worldNormal.y);
				o.t2w_2.xyz = float3(worldTangent.z, worldBinormal.z, worldNormal.z);

				//calc world pos
				float3 worldPos = mul(_Object2World, i.vertex).xyz;
				o.t2w_0.w = worldPos.x;
				o.t2w_1.w = worldPos.y;
				o.t2w_2.w = worldPos.z;


				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				fixed3 worldLight = normalize( _WorldSpaceLightPos0 );
				fixed3 worldView = normalize( _WorldSpaceCameraPos - float3(i.t2w_0.w, i.t2w_1.w, i.t2w_2.w) );
				fixed3 worldHalf = normalize( worldLight + worldView );

				fixed3 packedNormal = UnpackNormal( tex2D(_BumpMap, i.uv) );
				packedNormal.xy *= _BumpScale;
				packedNormal.z = sqrt( 1.0 - saturate(dot(packedNormal.xy, packedNormal.xy)) );
				fixed3 worldNormal = normalize( half3(dot(i.t2w_0.xyz, packedNormal), dot(i.t2w_1.xyz, packedNormal), dot(i.t2w_2.xyz, packedNormal)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 diffuse = albedo * _Color * _LightColor0 * saturate( dot(worldLight, worldNormal) );

				float specMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
				fixed3 specular = _LightColor0 * _Specular * pow(saturate( dot(worldHalf, worldNormal) ), _Shininess) * specMask;

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"
}