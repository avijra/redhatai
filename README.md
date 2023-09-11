# redhatai 🚀

![Screenshot 2023-09-11 at 10 57 32 PM](https://github.com/avijra/redhatai/assets/6593419/c58a9381-e309-4228-bd17-deef0d7ab54d)



### 🛠️ Installation:
1. Clone the repository:
```
git clone [<URL-of-your-repo>](https://github.com/avijra/redhatai.git)
```

3. In the root folder, create a new directory:
```
mkdir SOURCE_DOCUMENTS
```


### 🔧 Local Setup:
1. Install required libraries:
```
pip install -r requirements.txt
```

3. Start the app:
```
streamlit run redhat_ai.py
```


### 🐳 Docker Setup:
1. Build the Docker image:
```
docker build . -t name_of_image:version
```


3. Running with GPUs:
- Ensure you have NVIDIA Docker utilities:
  ```
  yum install nvidia-container-toolkit
  ```
- Start the container:
  ```
  docker run -p 8501:8501 -it --mount src="$HOME/.cache",target=/root/.cache,type=bind --gpus=all name_of_image:version
  ```

3. If not using GPUs:
   ```
   docker run -p 8501:8501 -it --mount src="$HOME/.cache",target=/root/.cache name_of_image:version
   ```

4. Alternatively, pull images directly:
   ```
   docker pull avijra/redhatai_vicuna-13b-gptq:1.0
   docker pull avijra/redhatai_vicuna-7b-gptq:1.0
   ```


### 📝 Things to Note:
1. Image building and downloading takes time due to size (~20GB). Relax and sip your coffee ☕.
2. First app run will be slower due to model download.
3. App response time varies based on GPU VRAM. Estimate: 48 GiB.
4. Code currently supports only 2 CUDA devices. To accommodate more, adjust in `run_redhatai.py`. 
- For example:
  ```python
  # Current Setup
  model = AutoGPTQForCausalLM.from_quantized(
      ...
      max_memory={ 0: "15GIB", 1: "15GIB" },
      ...
  )
  
  # Adjusted for 3 devices
  model = AutoGPTQForCausalLM.from_quantized(
      ...
      max_memory={ 0: "15GIB", 1: "15GIB", 2: "15GIB" },
      ...
  )
  ```


   

