﻿// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Color", Color) = (1,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        // 漫反射 逐顶点
        
        // 公式   ( n * l ) * Mdiffuse * CLight
        
        // saturate(x) 函数 将x限定在 [0,1] 标量 和 向量 都支持 

        Pass
        {
            LOD 100
            
            Tags { "LightMode"="ForwardBase" }

            Name "VertexLit"
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 color : COLOR0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            fixed4 _MainColor;
            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldNormal = normalize(mul(v.normal,unity_WorldToObject));
                fixed3 lightColor = _LightColor0.rgb;
                fixed3 color = lightColor * saturate(dot(worldNormal,worldLightDir)) * _MainColor;
                o.color = color + ambient;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col = col * float4(i.color,1.0);
                return col;
            }
            ENDCG
        }
    }
}
