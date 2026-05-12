(() => {
  const taskName = document.body.dataset.task || "task";
  const phase = document.body.dataset.phase || "phase";
  const storageKey = `plan-repl-html::${taskName}::${phase}`;

  // ---- state ----
  const state = (() => {
    try { return JSON.parse(localStorage.getItem(storageKey)) || { notes: {}, checks: {} }; }
    catch { return { notes: {}, checks: {} }; }
  })();
  const save = () => localStorage.setItem(storageKey, JSON.stringify(state));

  // ---- ToC ----
  const tocList = document.getElementById("toc-list");
  document.querySelectorAll("main section.annot[id]").forEach(s => {
    const heading = s.querySelector("h2, h3");
    if (!heading) return;
    const li = document.createElement("li");
    const a = document.createElement("a");
    a.href = "#" + s.id;
    a.textContent = heading.textContent;
    li.appendChild(a);
    tocList.appendChild(li);
  });

  // ---- annotation widget ----
  // Three states per section:
  //   Empty   — no saved note. Textarea is open for typing; only [Save] shown.
  //             Save is disabled until content exists.
  //   Saved   — a note is saved. Textarea is locked; [Clear] [Edit] shown.
  //   Editing — user clicked Edit on a saved note. Textarea is open with the
  //             stored value; [Cancel] [Save] shown.
  // The notes box stays visible at all times so reviewers see the field
  // without an extra click.
  const sections = document.querySelectorAll("section.annot[data-annot-id]");
  const syncers = [];
  sections.forEach(section => {
    const id = section.dataset.annotId;
    const heading = section.querySelector("h2, h3");
    const sectionLabel = heading ? heading.textContent.trim() : id;
    const box = document.createElement("div");
    box.className = "annot-box";
    box.innerHTML = `
      <div class="annot-box-head">
        <span>Notes</span>
        <span class="annot-box-status" data-state="empty"></span>
      </div>
      <textarea data-textarea placeholder="Add a note for this section…"></textarea>
      <div class="row">
        <button type="button" class="btn" data-action="clear" hidden>Clear</button>
        <button type="button" class="btn" data-action="edit" hidden>Edit</button>
        <button type="button" class="btn" data-action="cancel" hidden>Cancel</button>
        <button type="button" class="btn primary" data-action="save">Save</button>
      </div>`;
    section.appendChild(box);

    const textarea = box.querySelector("[data-textarea]");
    textarea.setAttribute("aria-label", `Notes for: ${sectionLabel}`);
    const statusEl = box.querySelector(".annot-box-status");
    const editBtn = box.querySelector('[data-action="edit"]');
    const clearBtn = box.querySelector('[data-action="clear"]');
    const cancelBtn = box.querySelector('[data-action="cancel"]');
    const saveBtn = box.querySelector('[data-action="save"]');

    let editing = false;

    const sync = () => {
      const stored = state.notes[id] || "";
      const has = !!stored.trim();
      section.classList.toggle("has-note", has);
      statusEl.dataset.state = has ? "saved" : "empty";
      statusEl.textContent = has ? "● saved" : "";
      if (!editing) {
        textarea.value = stored;
        textarea.disabled = has;          // locked when saved, open when empty
        editBtn.hidden = !has;
        clearBtn.hidden = !has;
        cancelBtn.hidden = true;
        saveBtn.hidden = has;             // hidden in Saved state
        saveBtn.disabled = !has;
      }
    };
    syncers.push(sync);

    const enterEditing = () => {
      editing = true;
      textarea.disabled = false;
      editBtn.hidden = true;
      clearBtn.hidden = true;
      cancelBtn.hidden = false;
      saveBtn.hidden = false;
      saveBtn.disabled = false;
      statusEl.dataset.state = "editing";
      statusEl.textContent = "editing…";
      textarea.focus();
    };
    const exitEditing = () => { editing = false; sync(); };

    sync();

    textarea.addEventListener("input", () => {
      // In Empty state, Save is gated on having content.
      if (!editing && !section.classList.contains("has-note")) {
        saveBtn.disabled = !textarea.value.trim();
      }
    });
    editBtn.addEventListener("click", enterEditing);
    cancelBtn.addEventListener("click", exitEditing);
    saveBtn.addEventListener("click", () => {
      const v = textarea.value.trim();
      if (v) state.notes[id] = v; else delete state.notes[id];
      save();
      exitEditing();
      updateCount();
    });
    clearBtn.addEventListener("click", () => {
      delete state.notes[id];
      save();
      exitEditing();
      updateCount();
    });
  });

  // ---- code-ref click-to-copy ----
  // navigator.clipboard requires a secure context and may be absent under
  // file:// in some browsers. On failure, surface a visible "copy failed"
  // hint instead of silently dropping the action.
  const flashState = (el, cls) => {
    el.classList.add(cls);
    setTimeout(() => el.classList.remove(cls), 800);
  };
  document.querySelectorAll(".code-ref").forEach(el => {
    el.addEventListener("click", async () => {
      if (!navigator.clipboard?.writeText) {
        flashState(el, "copy-failed");
        return;
      }
      try {
        await navigator.clipboard.writeText(el.textContent);
        flashState(el, "copied");
      } catch {
        flashState(el, "copy-failed");
      }
    });
  });

  // ---- todo checkboxes (only render if present) ----
  document.querySelectorAll('ul.todos input[type="checkbox"][data-todo-id]').forEach(cb => {
    const id = cb.dataset.todoId;
    cb.checked = !!state.checks[id];
    cb.closest("li").classList.toggle("done", cb.checked);
    cb.addEventListener("change", () => {
      state.checks[id] = cb.checked;
      save();
      cb.closest("li").classList.toggle("done", cb.checked);
    });
  });

  // ---- export ----
  const countEl = document.getElementById("annot-count");
  const updateCount = () => {
    const n = Object.keys(state.notes).length;
    countEl.textContent = n === 1 ? "1 note" : `${n} notes`;
  };
  updateCount();

  document.getElementById("annot-clear").addEventListener("click", () => {
    if (!confirm("Clear all notes on this page? (Checkbox state stays.)")) return;
    state.notes = {};
    save();
    syncers.forEach(fn => fn());
    updateCount();
  });

  document.getElementById("annot-export").addEventListener("click", () => {
    const annotations = Object.entries(state.notes).map(([section_id, note]) => {
      const section = document.querySelector(`section.annot[data-annot-id="${section_id}"]`);
      let excerpt = "";
      if (section) {
        // Clone and strip the injected notes box so its UI text doesn't
        // leak into the excerpt ("Notes ● saved Edit Clear Cancel Save").
        const clone = section.cloneNode(true);
        clone.querySelector(".annot-box")?.remove();
        excerpt = clone.textContent.replace(/\s+/g, " ").trim().slice(0, 120);
      }
      return { section_id, section_excerpt: excerpt, note };
    });
    const payload = {
      task: taskName,
      phase: phase,
      exported_at: new Date().toISOString(),
      annotations,
      checks: state.checks
    };
    const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `${taskName}.${phase}.annotations.json`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
  });
})();
