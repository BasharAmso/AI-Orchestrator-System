# Beginner's Guide

You describe what you want to build. The system builds it. No coding required.

This guide takes you from nothing to a working app. It assumes you've never used a terminal, never written code, and never heard of Claude Code. If any of that sounds like you, you're in the right place.

---

## What You Need

Four things, all free except the Claude subscription.

### 1. A Computer

Windows, Mac, or Linux. Anything made in the last 10 years works.

### 2. Node.js

Node.js is a tool that lets you run the install command. You won't use it directly after that.

1. Go to https://nodejs.org
2. Click the big green button that says **LTS** (that's the stable version)
3. Run the installer
4. Click **Next** through everything -- the defaults are fine

To check it worked, open any terminal and type `node --version`. You should see a version number.

### 3. VS Code + Claude Code

VS Code is a free text editor for projects. Claude Code is an AI assistant that runs inside it.

1. Go to https://code.visualstudio.com and download VS Code
2. Install it (defaults are fine)
3. Open VS Code
4. Click the **Extensions** icon on the left sidebar (it looks like four squares)
5. Search for **Claude Code**
6. Click **Install**
7. Claude Code will ask you to sign in. Follow the prompts.

### 4. A Claude Subscription

Claude Code requires a paid Claude subscription (Pro or Max plan). Sign up at https://claude.ai if you don't have one. The sign-in flow in step 7 above will walk you through it.

---

## Install the Framework

This takes about 2 minutes.

1. Open VS Code
2. Open the terminal. Look at the bottom of VS Code. There's a dark panel with a blinking cursor. That's the terminal. If you don't see it, click **View** in the top menu, then click **Terminal**.
3. Type this and press Enter:

```
npx create-bashi my-first-app
```

You'll see something like:

```
Bashi v2.1.0
12 agents | 37 skills | 20 commands | 11 safety hooks

Installing framework...

  Copied:  106 files

Framework installed successfully!

Next steps:
  1. cd my-first-app
  2. Open in VS Code with Claude Code
  3. Run /start
```

4. Now open the new folder. Click **File** in the top menu, then **Open Folder**, and find `my-first-app` wherever you created it. Click **Open**.

---

## Build Your First App

You're going to type a few short commands. Each one does something specific. The system tells you what to do next after each step.

### Step 1: Type `/start`

In the Claude Code chat panel, type `/start` and press Enter.

This is like opening the dashboard. It checks where you are and tells you what to do next. The first time, it will ask you a few questions about how you like to work. Answer them -- it takes 30 seconds.

### Step 2: Type `/setup`

Type `/setup` and press Enter.

This sets up your project. It will ask you:
- What's your project called?
- What are you trying to build? (Describe it in a sentence or two)
- What type of app is it? (It will suggest one based on your description -- you pick)

Answer the questions. The system creates the folder structure for your project.

### Step 3: Type `/capture-idea`

Type `/capture-idea` and press Enter.

Now describe what you want to build. Write in plain English. Here are some examples:

> "I want to build a website for my chocolate business where customers can browse products, place orders, and track delivery."

> "I want to build a fun educational game for my kids where they explore a world and answer questions to unlock new areas."

> "I want to build a personal training website where clients can book sessions, see their workout plans, and track progress."

The system takes your description and creates a plan: what features to build, what order to build them, and what the final product should look like.

### Step 4: Type `/run-project`

Type `/run-project` and press Enter.

This is where the magic happens. The system picks up your idea and starts working on it. The first time, it usually:
- Writes a detailed product plan
- Designs the app structure
- Breaks everything into small tasks

### Step 5: Keep typing `/run-project`

Each time you type `/run-project`, the system completes the next task. It might:
- Create a page layout
- Build a navigation menu
- Set up a database
- Add a contact form

After each task, it shows you what it did and what's next. Keep going until it says the queue is empty.

---

## What Just Happened?

While you were typing those commands, the system:

1. **Planned** your entire app (features, architecture, task list)
2. **Built** each piece one at a time (pages, components, logic)
3. **Reviewed** its own work after each step
4. **Tracked** everything in a state file so nothing gets lost

Your project files are in the folder you opened. The actual app code is usually in `src/`. The plans and documents are in `docs/`.

When the system tells you the app is ready to preview, it will include instructions for how to see it in your browser.

---

## Saving and Coming Back

This is important:

**Always type `/save` before closing VS Code.** This saves your progress to files. If you skip this step, you might have to redo work next time.

When you come back:
1. Open the same folder in VS Code
2. Type `/start`
3. It picks up exactly where you left off

---

## Tips

- **You can't break anything.** The system has safety guards. If something goes wrong, it rolls back automatically.
- **Talk to it like a person.** You don't need special commands for everything. If you're confused, just ask: "What should I do next?"
- **One step at a time.** Don't try to build everything at once. Let the system plan and pace the work.
- **Save often.** Type `/save` whenever you step away, even for a few minutes.

---

## What's Next?

Once you're comfortable with the basics, there's a lot more you can do:

- **[User Guide](USER_GUIDE.md)** -- full walkthrough of every command and feature
- **[README](../README.md)** -- advanced features like overnight mode (the system works while you sleep), parallel execution (multiple tasks at once), and MCP-connected mode

You don't need to learn any of that right now. The four commands above (`/start`, `/setup`, `/capture-idea`, `/run-project`) are enough to build real apps.
